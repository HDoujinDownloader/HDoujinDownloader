-- Kagane. The site moves between mirror domains. The module uses the "Default mirror" setting
-- (kagane.net) and only if that domain is gone does it ask kagane.org for the current mirrors.

local DEFAULT_MIRROR      = 'kagane.net'
local MIRROR_TRACKER      = 'https://kagane.org/'
-- Public DNS-over-HTTPS lookup, used to check that a domain still exists before contacting it:
-- a request to a domain that doesn't resolve throws an exception HDD can't recover from.
local DNS_RESOLVER        = 'https://dns.google/resolve?type=A&name='
local CACHE_SECONDS       = 300
local MIRROR_LIST_SECONDS = 6 * 60 * 60

-- Domains whose URLs this module accepts. Mirror *selection* is dynamic (see GetSiteBase),
-- but HDD needs URL domains registered up front, so this seeds the list; mirrors learned
-- from kagane.org are added on the next start.
local SEED_DOMAINS        = { 'kagane.net', 'kagane.cx', 'kagane.moe', 'kagane.org', 'kagane.to' }

function Register()
    module.Name     = 'Kagane'
    module.Language = 'English'
    -- The site hosts 18+ series; each series is flagged individually in GetInfo().
    module.Adult    = true

    local domains, seen = {}, {}
    for _, domain in ipairs(SEED_DOMAINS) do
        table.insert(domains, domain)
        seen[domain] = true
    end
    for domain in tostring(module.Data['mirrors']):gmatch('[^,]+') do
        if domain:match('^kagane%.%a+$') and not seen[domain] then
            table.insert(domains, domain)
            seen[domain] = true
        end
    end

    for _, domain in ipairs(domains) do
        module.Domains.Add(domain, 'Kagane')
        -- Throttle API calls (not image downloads, which come from the kstatic.to CDN) to
        -- avoid tripping Cloudflare. Raise the first number if this feels too slow.
        module.RateLimits.Add(domain .. '/api/', 3, 1000)
    end

    -- Image downloads come from the kstatic.to CDN. Uncomment to throttle them too
    -- (e.g. 2 images per second), if HDD applies module rate limits to page downloads:
    -- module.RateLimits.Add('kstatic.to', 2, 1000)

    if not module.Settings.Contains('Adult flag') then
        module.Settings.AddChoice('Adult flag', 'Pornographic only', { 'Pornographic only', 'All 18+' })
            .WithToolTip('Which series get HDD\'s Adult flag. Every series also gets a "Rated ..." tag either way.')
    end
    if not module.Settings.Contains('Cover size') then
        module.Settings.AddChoice('Cover size', 'Full', { 'Full', 'Compressed' })
            .WithToolTip('Full = original cover image. Compressed = the smaller version the site displays. (HDD can\'t resize Kagane\'s WebP covers itself.)')
    end
    if not module.Settings.Contains('Default mirror') then
        module.Settings.AddText('Default mirror', DEFAULT_MIRROR)
            .WithToolTip('Always used while it works. kagane.org is only checked for another mirror if this domain no longer exists or its API fails.')
    end
end

-- Matches a UUID optionally preceded by a slug ("kaine-<uuid>",
-- "vol-1-chapter-2-<uuid>") or bare ("<uuid>"). The greedy slug group
-- backtracks to the last position where a full UUID still fits.
local UUID_RX = '(?:[^/?#]*-)?([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})'

-- Caches keyed by seriesId, so GetInfo() and GetChapters() (which HDD
-- calls back-to-back for the same series) don't each pay for a separate
-- Cloudflare-challenged request. Entries expire so that "Check for
-- downloads" still sees new chapters if HDD keeps this module loaded.
local _seriesCache = {}
local _indexCache  = {}
local _siteBase, _siteBaseTime

local function CacheGet(cache, key)
    local entry = cache[key]
    if entry and os.time() - entry.time < CACHE_SECONDS then
        return entry.value
    end
    return nil
end

local function CacheSet(cache, key, value)
    cache[key] = { value = value, time = os.time() }
end

local function HostOf(u)
    return tostring(u):regex('^https?://([^/:?#]+)', 1):lower()
end

local function IsMirrorHost(host)
    return host:match('^kagane%.%a+$') ~= nil and host ~= 'kagane.org' and host ~= 'kagane.to'
end

local function ClearApiHeaders()
    -- Keep the integrity token off later requests (image downloads go to the CDN).
    -- Content-Type is left alone: it's harmless on GETs, and clearing it is untested.
    http.Headers['X-Integrity-Token'] = nil
end

local function SetApiHeaders(siteBase)
    http.Headers['Referer'] = siteBase .. '/'
end

-- Turns a non-200 response into a readable error instead of a raw WebException.
local function CheckResponse(resp, what)
    local code = tonumber(tostring(resp.StatusCode)) or 0
    if code == 200 then return end
    if code == 401 then
        Fail(Error.LoginRequired)
    elseif code == 403 then
        error('Kagane: 403 Forbidden from ' .. what .. ' (likely a Cloudflare block; try solving the challenge in the browser)')
    elseif code == 404 then
        error('Kagane: 404 Not Found from ' .. what .. ' (series/chapter removed or wrong ID)')
    else
        error('Kagane: HTTP ' .. code .. ' from ' .. what)
    end
end

local function NormalizeHost(host)
    host = tostring(host):trim():lower()
    if host:contains('://') then host = HostOf(host) end
    host = host:trim('/'):gsub('^www%.', '')
    return host
end

-- The "Default mirror" setting as a bare host (kagane.net if blank/invalid).
local function GetDefaultMirror()
    local setting = module.Settings['Default mirror']
    if not isempty(setting) then
        local host = NormalizeHost(setting)
        if IsMirrorHost(host) then return host end
    end
    return DEFAULT_MIRROR
end

-- Whether the domain still exists, asked through public DNS-over-HTTPS (a separate client,
-- so no site cookies or headers go to the resolver). If the resolver itself can't be
-- reached, the domain is assumed to exist.
local function Resolves(host)
    local resp = Http.New().GetResponse(DNS_RESOLVER .. host)
    if resp.StatusCode ~= 200 then
        Log('Kagane: DNS check for ' .. host .. ' failed (HTTP ' .. tostring(resp.StatusCode) .. '), assuming it exists')
        return true
    end
    local json = Json.New(resp.Body)
    local resolves = tostring(json.SelectValue('Status')) == '0' and json.SelectValues('Answer[*].data').Count() > 0
    if not resolves then
        Log('Kagane: ' .. host .. ' no longer resolves')
    end
    return resolves
end

-- Whether the domain exists and its API answers.
local function MirrorWorks(host)
    if not Resolves(host) then return false end
    local resp = http.GetResponse('https://' .. host .. '/api/v2/config/client')
    if resp.StatusCode == 200 then return true end
    Log('Kagane: mirror ' .. host .. ' returned HTTP ' .. tostring(resp.StatusCode))
    return false
end

-- The mirrors kagane.org currently lists, kept in module.Data for MIRROR_LIST_SECONDS so
-- kagane.org (Cloudflare-protected) isn't hit again on every download while the default
-- mirror is down. Nothing is hardcoded: if kagane.org can't be read and there's no saved
-- list, there's nothing to fall back to.
local function GetListedMirrors()
    local cached = {}
    for host in tostring(module.Data['mirrors']):gmatch('[^,]+') do
        if IsMirrorHost(host) then table.insert(cached, host) end
    end
    local cachedTime = tonumber(module.Data['mirrorsTime']) or 0
    if #cached > 0 and os.time() - cachedTime < MIRROR_LIST_SECONDS then
        return cached
    end

    Log('Kagane: checking kagane.org for mirrors')
    local listed = {}
    local tracker = http.GetResponse(MIRROR_TRACKER)
    if tracker.StatusCode == 200 then
        for href in Dom.New(tracker.Body).SelectValues('//a[starts-with(@href,"https://kagane.")]/@href') do
            local host = HostOf(href)
            if IsMirrorHost(host) then table.insert(listed, host) end
        end
    end

    if #listed > 0 then
        module.Data['mirrors'] = table.concat(listed, ',')
        module.Data['mirrorsTime'] = tostring(os.time())
        return listed
    end

    Log('Kagane: could not read the mirror list from kagane.org (HTTP ' .. tostring(tracker.StatusCode) .. ')')
    return cached
end

-- The site root to use for API calls, e.g. "https://kagane.net". The default mirror is used
-- while it works; only if it's gone are kagane.org's mirrors tried. The choice is remembered
-- for CACHE_SECONDS (and a fallback mirror in module.Data, so later downloads don't repeat
-- the search while the default is down).
local function GetSiteBase()
    if _siteBase and os.time() - _siteBaseTime < CACHE_SECONDS then
        return _siteBase
    end

    local function use(host)
        _siteBase, _siteBaseTime = 'https://' .. host, os.time()
        Log('Kagane: using mirror ' .. host)
        return _siteBase
    end

    local default = GetDefaultMirror()
    if MirrorWorks(default) then
        module.Data['fallbackMirror'] = ''
        return use(default)
    end

    local tried = { default }
    local lastFallback = module.Data['fallbackMirror']
    if IsMirrorHost(tostring(lastFallback)) and lastFallback ~= default then
        table.insert(tried, lastFallback)
        if MirrorWorks(lastFallback) then return use(lastFallback) end
    end

    for _, host in ipairs(GetListedMirrors()) do
        if host ~= default and host ~= lastFallback then
            table.insert(tried, host)
            if MirrorWorks(host) then
                module.Data['fallbackMirror'] = host
                return use(host)
            end
        end
    end

    error('Kagane: no working mirror found (tried: ' .. table.concat(tried, ', ') ..
          '). Check kagane.org, or change "Default mirror".')
end

local function GetSeriesId()
    return tostring(url):regex('/series/' .. UUID_RX, 1)
end

local function GetBookId()
    return tostring(url):regex('/reader/' .. UUID_RX, 1)
end

local function ApiGet(path)
    local siteBase = GetSiteBase()
    SetApiHeaders(siteBase)
    local resp = http.GetResponse(siteBase .. '/api/v2' .. path)
    ClearApiHeaders()
    CheckResponse(resp, path)
    return Json.New(resp.Body)
end

-- GET /series/{id}: metadata only (title, staff, genres, tags, covers...).
local function ApiGetSeries(seriesId)
    local json = CacheGet(_seriesCache, seriesId)
    if json == nil then
        json = ApiGet('/series/' .. seriesId)
        CacheSet(_seriesCache, seriesId, json)
    end
    return json
end

-- GET /series/{id}/books/index?fields=List: the chapter list.
-- Shape:
--   { "count": N,
--     "fields": ["book_id","sort_no","chapter_no","volume_no","group_ix",
--                "released_at","title","page_count","published_on",
--                "internal_release"],
--     "groups": [ { "group_id": ..., "title": ..., "is_scanlator": ... }, ... ],
--     "books":  [ ["<uuid>", 2, "2", "1", [0], 1792718279, "Title", 31, ...], ... ] }
local function ApiGetBookIndex(seriesId)
    local json = CacheGet(_indexCache, seriesId)
    if json == nil then
        json = ApiGet('/series/' .. seriesId .. '/books/index?fields=List')
        CacheSet(_indexCache, seriesId, json)
    end
    return json
end

-- Returns a Lua table mapping field name -> 0-based column index, built
-- from the index's "fields" header, so we don't hardcode column positions
-- that the site could reorder.
local function GetIndexColumns(json)
    local cols = {}
    local i = 0
    for field in json.SelectValues('fields[*]') do
        cols[tostring(field)] = i
        i = i + 1
    end
    return cols
end

-- Reads one cell from a row of the columnar books table. Done per-cell
-- (rather than SelectValues over a whole column) so a null title in one
-- row can't shift every later row out of alignment.
local function RowCell(row, col)
    if col == nil then return nil end
    return row.SelectValue('[' .. col .. ']')
end

-- "2.0" -> "2", "2.5" stays "2.5".
local function TrimNumber(s)
    if isempty(s) then return s end
    s = tostring(s)
    return (s:gsub('%.0+$', ''))
end

-- Fetches a fresh integrity token and attaches it as a header before a
-- protected POST call. Tokens are short-lived, so we always fetch a new
-- one rather than caching. The client sends either no body or
-- {"fp": "<fingerprint hash>"}; the fingerprint is optional.
local function SetIntegrityHeader(siteBase)
    SetApiHeaders(siteBase)
    http.Headers['X-Integrity-Token'] = nil
    http.Headers['Content-Type'] = 'application/json'

    local resp = http.PostResponse(siteBase .. '/api/integrity', '')
    CheckResponse(resp, '/api/integrity')
    local token = Json.New(resp.Body).SelectValue('token')

    if isempty(token) then
        ClearApiHeaders()
        error('Kagane: failed to obtain integrity token (POST /api/integrity did not return one)')
    end

    http.Headers['X-Integrity-Token'] = token
end

-- POST wrapper for the chapter grant endpoint. The current client sends
-- no body; '{}' was required by the previous API and is kept because the
-- endpoint accepted it then. If this starts returning 400, try ''.
local function ApiPost(path)
    local siteBase = GetSiteBase()
    SetIntegrityHeader(siteBase)
    local resp = http.PostResponse(siteBase .. '/api/v2' .. path, '{}')
    ClearApiHeaders()
    CheckResponse(resp, path)
    return Json.New(resp.Body)
end

local function GetCoverUrl(json)
    local imageId = nil
    for cover in json.SelectNodes('series_covers[*]') do
        if imageId == nil then
            imageId = cover.SelectValue('image_id')
        end
        if tostring(cover.SelectValue('is_main')):lower() == 'true' then
            imageId = cover.SelectValue('image_id')
            break
        end
    end
    if isempty(imageId) then return nil end
    -- Kagane only serves covers as WebP. HDD always saves covers as cover.jpg first,
    -- renames the file to cover.webp, and then its resize step fails looking for
    -- cover.jpg, so the cover is kept at whatever size it was downloaded at. The
    -- "Cover size" setting picks between the full image and the site's small version.
    local coverUrl = GetSiteBase() .. '/api/v2/image/' .. imageId
    if module.Settings['Cover size'] == 'Compressed' then
        coverUrl = coverUrl .. '/compressed'
    end
    return coverUrl
end

function GetInfo()
    local seriesId = GetSeriesId()
    if isempty(seriesId) then
        error('Kagane: no series ID found in URL ' .. tostring(url))
    end
    local json = ApiGetSeries(seriesId)

    info.Id               = seriesId
    info.Title            = json.SelectValue('title')
    info.AlternativeTitle = json.SelectValues('series_alternate_titles[*].title')
    info.Status           = json.SelectValue('publication_status')
    info.Summary          = json.SelectValue('description')
    info.Type             = json.SelectValue('format')
    info.Language         = json.SelectValue('translated_language')
    info.DateReleased     = json.SelectValue('start_year')
    info.ThumbnailUrl     = GetCoverUrl(json)

    -- average_rating is 0-100; the site shows it out of 10 (77 -> 7.7).
    local rating = tonumber(tostring(json.SelectValue('average_rating')))
    if rating then
        info.CommunityRating = string.format('%.1f', rating / 10)
    end

    -- Native title: the first alternate title written in the original language's
    -- script. Labels can't be trusted (migrated series label every title "ja",
    -- including Vietnamese and Korean ones), so match on characters instead.
    local NATIVE_SCRIPT = {
        ja = '[\\u3040-\\u30ff\\u4e00-\\u9fff]',   -- kana or kanji
        ko = '[\\uac00-\\ud7af\\u1100-\\u11ff]',   -- Hangul
        zh = '[\\u4e00-\\u9fff]',                   -- Han
    }
    local originalLanguage = tostring(json.SelectValue('original_language')):lower():sub(1, 2)
    local script = NATIVE_SCRIPT[originalLanguage]
    if script then
        for title in json.SelectValues('series_alternate_titles[*].title') do
            if not isempty(tostring(title):regex(script)) then
                info.OriginalTitle = title
                break
            end
        end
    end

    -- The site shows four ratings, built from two fields:
    --   Safe / 15+ / 18+  = age_rating Safe / FifteenPlus / EighteenPlus
    --   18+ Pornographic  = age_rating EighteenPlus + is_pornographic true
    -- 18+ is also matched loosely (e.g. "18+") in case the API spelling changes.
    local ageRating   = tostring(json.SelectValue('age_rating')):lower()
    local isPorn      = tostring(json.SelectValue('is_pornographic')):lower() == 'true'
    local isDisturbing = tostring(json.SelectValue('is_disturbing')):lower() == 'true'
    local isMature    = ageRating == 'eighteenplus' or ageRating:find('18') ~= nil
    local ratingLabel = nil
    if isPorn then
        ratingLabel = '18+ Pornographic'
    elseif isMature then
        ratingLabel = '18+'
    elseif ageRating == 'fifteenplus' or ageRating:find('15') ~= nil then
        ratingLabel = '15+'
    elseif ageRating == 'safe' then
        ratingLabel = 'Safe'
    end

    if module.Settings['Adult flag'] == 'All 18+' then
        info.Adult = isMature or isPorn
    else
        info.Adult = isPorn
    end

    local tags = List.New()
    tags.AddRange(json.SelectValues('genres[*].genre_name'))
    tags.AddRange(json.SelectValues('tags[*].tag_name'))
    -- Plain tags (no "Namespace: value" form), since HDD writes a namespaced tag as just its value.
    if ratingLabel then
        tags.Add('Rated ' .. ratingLabel)
    end
    -- Separate from the age rating: the site flags disturbing content on its own.
    if isDisturbing then
        tags.Add('Disturbing Content')
    end
    info.Tags = tags.Distinct()

    -- Staff roles seen: "Story", "Art". A person with both roles is listed once per role.
    local authors, artists, everyone = List.New(), List.New(), List.New()
    for staff in json.SelectNodes('series_staff[*]') do
        local name = staff.SelectValue('name')
        local role = tostring(staff.SelectValue('role')):lower()
        if not isempty(name) then
            everyone.Add(name)
            if role:find('story') or role:find('author') or role:find('writer') then authors.Add(name) end
            if role:find('art') then artists.Add(name) end
        end
    end
    if authors.Count() == 0 and artists.Count() == 0 then
        authors, artists = everyone, everyone
    end
    info.Author = authors.Distinct()
    info.Artist = artists.Distinct()

    local index = ApiGetBookIndex(seriesId)

    local groupTitles = index.SelectValues('groups[*].title')
    if groupTitles.Count() > 0 then
        info.Translator = groupTitles[0]
        info.Scanlator  = groupTitles.Distinct()
    end

    local cols = GetIndexColumns(index)
    local chapterCount, pageCount = 0, 0
    for row in index.SelectNodes('books[*]') do
        chapterCount = chapterCount + 1
        pageCount = pageCount + (tonumber(tostring(RowCell(row, cols['page_count']))) or 0)
    end
    info.ChapterCount = chapterCount
    info.PageCount    = pageCount
end

function GetChapters()
    local seriesId = GetSeriesId()
    if isempty(seriesId) then
        error('Kagane: no series ID found in URL ' .. tostring(url))
    end
    local index    = ApiGetBookIndex(seriesId)
    local cols     = GetIndexColumns(index)
    local baseUrl  = GetSiteBase() .. '/series/' .. seriesId .. '/reader/'

    local groupTitles = {}
    for title in index.SelectValues('groups[*].title') do
        table.insert(groupTitles, title)
    end

    -- Collect rows first so they can be sorted by sort_no: the API returned
    -- them ascending in testing, but that was only checked on short series.
    local rows = {}
    for row in index.SelectNodes('books[*]') do
        local bookId = RowCell(row, cols['book_id'])
        if not isempty(bookId) then
            local groupIx = cols['group_ix'] and tonumber(tostring(row.SelectValue('[' .. cols['group_ix'] .. '][0]')))
            table.insert(rows, {
                bookId    = bookId,
                title     = RowCell(row, cols['title']),
                chapterNo = RowCell(row, cols['chapter_no']),
                volumeNo  = RowCell(row, cols['volume_no']),
                sortNo    = tonumber(tostring(RowCell(row, cols['sort_no']))) or 0,
                group     = groupIx and groupTitles[groupIx + 1] or nil,
            })
        end
    end
    table.sort(rows, function(a, b) return a.sortNo < b.sortNo end)

    for _, r in ipairs(rows) do
        local num = r.chapterNo
        if isempty(num) then num = TrimNumber(tostring(r.sortNo)) end

        local label = ''
        if not isempty(r.volumeNo) then
            label = 'Vol. ' .. r.volumeNo .. ' '
        end
        if not isempty(num) then
            label = label .. 'Chapter ' .. num
            if not isempty(r.title) then
                label = label .. ' - ' .. r.title
            end
        elseif not isempty(r.title) then
            label = label .. r.title
        else
            label = r.bookId
        end

        local chapter = ChapterInfo.New()
        chapter.Url     = baseUrl .. r.bookId
        chapter.Title   = label
        chapter.Chapter = num
        chapter.Volume  = r.volumeNo
        if r.group then
            chapter.ScanlationGroup = r.group
        end
        chapters.Add(chapter)
    end
end

function GetPages()
    local bookId = GetBookId()
    if isempty(bookId) then
        error('Kagane: no chapter ID found in URL ' .. tostring(url))
    end

    local json = ApiPost('/books/' .. bookId .. '?intent=Read')

    -- One token covers every page in this chapter.
    local token    = json.SelectValue('access_token')
    local cacheUrl = json.SelectValue('cache_url')
    if isempty(cacheUrl) then cacheUrl = 'https://kstatic.to' end
    cacheUrl = tostring(cacheUrl):gsub('/+$', '')

    if isempty(token) then
        error('Kagane: grant response had no access_token: ' .. json.ToString())
    end

    -- Image requests only need the site as Referer (API headers were cleared above).
    pages.Referer = GetSiteBase() .. '/'

    -- The client accepts the manifest either as {"pages": [...]} or as a
    -- bare array. Try the object form first (what the previous API used).
    local manifest = json.SelectNodes('manifest.pages[*]')
    if manifest.Count() == 0 then
        manifest = json.SelectNodes('manifest[*]')
    end
    if manifest.Count() == 0 then
        error('Kagane: no pages found in grant manifest: ' .. json.ToString())
    end

    for page in manifest do
        local pageId = page.SelectValue('page_id')
        local ext    = page.SelectValue('ext')
        if not isempty(pageId) and not isempty(ext) then
            pages.Add(cacheUrl .. '/api/v2/books/page/' .. bookId .. '/' ..
                      pageId .. '.' .. ext .. '?token=' .. token)
        end
    end
end
