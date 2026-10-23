function Register()
    module.Name     = 'Kagane'
    module.Language = 'English'
    module.Domains.Add('kagane.net',  'Kagane')
    module.Domains.Add('kagane.org', 'Kagane')
    module.Domains.Add('kagane.to',  'Kagane')

end

local SITE_BASE = 'https://kagane.net'
local API_BASE  = SITE_BASE .. '/api/v2'

-- Matches a UUID optionally preceded by a slug ("kaine-<uuid>",
-- "vol-1-chapter-2-<uuid>") or bare ("<uuid>"). The greedy slug group
-- backtracks to the last position where a full UUID still fits.
local UUID_RX = '(?:[^/?#]*-)?([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})'

-- Caches keyed by seriesId, so GetInfo() and GetChapters() (which HDD
-- calls back-to-back for the same series) don't each pay for a separate
-- Cloudflare-challenged request.
local _seriesCache = {}
local _indexCache  = {}

local function SetHeaders()
    http.Headers['Referer'] = SITE_BASE .. '/'
    local token = tostring(module.Settings['Auth Token'])
    if not isempty(token) then
        http.Headers['Authorization'] = 'Bearer ' .. token
    else
        http.Headers['Authorization'] = nil
    end
end

local function GetSeriesId()
    return tostring(url):regex('/series/' .. UUID_RX, 1)
end

local function GetBookId()
    return tostring(url):regex('/reader/' .. UUID_RX, 1)
end

-- GET /series/{id}: metadata only (title, staff, genres, tags...).
local function ApiGetSeries(seriesId)
    if _seriesCache[seriesId] then
        return _seriesCache[seriesId]
    end
    SetHeaders()
    local resp = http.Get(API_BASE .. '/series/' .. seriesId)
    local json = Json.New(resp)
    _seriesCache[seriesId] = json
    return json
end

-- GET /series/{id}/books/index?fields=List: the chapter list.
-- Shape:
--   { "count": N,
--     "fields": ["book_id","sort_no","chapter_no","volume_no","group_ix",
--                "released_at","title","page_count","published_on",
--                "internal_release"],
--     "groups": [ { "group_id": ..., "title": ... }, ... ],
--     "books":  [ ["<uuid>", 2.0, "2", "1", [0], 1792718279, "Title", 31, ...], ... ] }
local function ApiGetBookIndex(seriesId)
    if _indexCache[seriesId] then
        return _indexCache[seriesId]
    end
    SetHeaders()
    local resp = http.Get(API_BASE .. '/series/' .. seriesId .. '/books/index?fields=List')
    local json = Json.New(resp)
    _indexCache[seriesId] = json
    return json
end

-- Returns a Lua table mapping field name -> 0-based column index, built
-- from the index's "fields" header, so we don't hardcode column positions
-- that the site could reorder.
local function GetIndexColumns(json)
    local cols = {}
    local fields = json.SelectValues('fields[*]')
    for i = 0, fields.Count() - 1 do
        cols[tostring(fields[i])] = i
    end
    return cols
end

-- Reads one cell from the columnar books table. Done per-row/per-cell
-- (rather than SelectValues over a whole column) so a null title in one
-- row can't shift every later row out of alignment.
local function IndexCell(json, row, col)
    if col == nil then return nil end
    return json.SelectValue('books[' .. row .. '][' .. col .. ']')
end

-- "2.0" -> "2", "2.5" stays "2.5".
local function TrimNumber(s)
    if isempty(s) then return s end
    s = tostring(s)
    return (s:gsub('%.0+$', ''))
end

-- Fetches a fresh integrity token and attaches it as a header before a
-- protected POST call. Tokens are short-lived, so we always fetch a new
-- one rather than caching. If the fetch or parse fails, we explicitly
-- clear any previously-set header rather than leaving a stale token.
-- The client sends either no body or {"fp": "<fingerprint hash>"}; the
-- fingerprint is optional.
local function SetIntegrityHeader()
    SetHeaders()
    http.Headers['X-Integrity-Token'] = nil
    http.Headers['Content-Type'] = 'application/json'

    local resp = http.Post(SITE_BASE .. '/api/integrity', '')
    local json = Json.New(resp)
    local token = json.SelectValue('token')

    if isempty(token) then
        error('Kagane: failed to obtain integrity token (POST /api/integrity did not return one)')
    end

    http.Headers['X-Integrity-Token'] = token
end

-- POST wrapper for the chapter grant endpoint. The current client sends
-- no body; '{}' was required by the previous API and is kept because the
-- endpoint accepted it then. If this starts returning 400, try ''.
local function ApiPost(path)
    SetIntegrityHeader()
    local resp = http.Post(API_BASE .. path, '{}')
    http.Headers['X-Integrity-Token'] = nil
    return Json.New(resp)
end

function GetInfo()
    local seriesId = GetSeriesId()
    if isempty(seriesId) then return end
    local json = ApiGetSeries(seriesId)

    info.Title            = json.SelectValue('title')
    info.AlternativeTitle = json.SelectValues('series_alternate_titles[*].title')
    info.Status           = json.SelectValue('publication_status')
    info.Summary          = json.SelectValue('description')
    info.Type             = json.SelectValue('format')
    info.Language         = json.SelectValue('translated_language')
    info.DateReleased     = json.SelectValue('start_year')

    -- age_rating values seen: Safe, FifteenPlus, EighteenPlus.
    local ageRating = tostring(json.SelectValue('age_rating'))
    local porn      = tostring(json.SelectValue('is_pornographic')):lower()
    info.Adult = (ageRating == 'EighteenPlus') or (porn == 'true')

    local genreNames = json.SelectValues('genres[*].genre_name')
    local tagNames   = json.SelectValues('tags[*].tag_name')
    local tags = List.New()
    for i = 0, genreNames.Count() - 1 do
        tags.Add(genreNames[i])
    end
    for i = 0, tagNames.Count() - 1 do
        tags.Add(tagNames[i])
    end
    info.Tags = tags

    info.Author = json.SelectValues('series_staff[*].name')
    info.Artist = json.SelectValues('series_staff[*].name')

    local index = ApiGetBookIndex(seriesId)

    local groupTitles = index.SelectValues('groups[*].title')
    if groupTitles.Count() > 0 then
        info.Translator = groupTitles[0]
    end

    local chapterCount = tonumber(tostring(index.SelectValue('count'))) or 0
    info.PageCount    = chapterCount
    info.ChapterCount = chapterCount
end

function GetChapters()
    local seriesId = GetSeriesId()
    if isempty(seriesId) then return end
    local index   = ApiGetBookIndex(seriesId)
    local cols    = GetIndexColumns(index)
    local baseUrl = SITE_BASE .. '/series/' .. seriesId .. '/reader/'

    local count = tonumber(tostring(index.SelectValue('count'))) or 0

    for i = 0, count - 1 do
        local bookId    = IndexCell(index, i, cols['book_id'])
        local title     = IndexCell(index, i, cols['title'])
        local chapterNo = IndexCell(index, i, cols['chapter_no'])
        local volumeNo  = IndexCell(index, i, cols['volume_no'])
        local sortNo    = IndexCell(index, i, cols['sort_no'])

        if not isempty(bookId) then
            local num = chapterNo
            if isempty(num) then num = TrimNumber(sortNo) end

            local label = ''
            if not isempty(volumeNo) then
                label = 'Vol. ' .. volumeNo .. ' '
            end
            if not isempty(num) then
                label = label .. 'Chapter ' .. num
                if not isempty(title) then
                    label = label .. ' - ' .. title
                end
            elseif not isempty(title) then
                label = label .. title
            else
                label = bookId
            end

            chapters.Add(baseUrl .. bookId, label)
        end
    end

    -- No chapters.Reverse(): books/index returned rows in ascending
    -- sort_no order in the Oct 2026 capture (only a 2-chapter sample, so
    -- re-check this on a longer series).
end

function GetPages()
    local bookId = GetBookId()
    if isempty(bookId) then return end

    local json = ApiPost('/books/' .. bookId .. '?intent=Read')

    -- One token covers every page in this chapter.
    local token    = json.SelectValue('access_token')
    local cacheUrl = json.SelectValue('cache_url')
    if isempty(cacheUrl) then cacheUrl = 'https://kstatic.to' end
    cacheUrl = tostring(cacheUrl):gsub('/+$', '')

    if isempty(token) then
        error('Kagane: grant response had no access_token: ' .. json.ToString())
    end

    -- The client accepts the manifest either as {"pages": [...]} or as a
    -- bare array. Try the object form first (what the previous API used).
    local prefix = 'manifest.pages'
    local pageIds = json.SelectValues(prefix .. '[*].page_id')
    if pageIds.Count() == 0 then
        prefix  = 'manifest'
        pageIds = json.SelectValues(prefix .. '[*].page_id')
    end
    if pageIds.Count() == 0 then
        error('Kagane: no pages found in grant manifest: ' .. json.ToString())
    end

    for i = 0, pageIds.Count() - 1 do
        local pageId = json.SelectValue(prefix .. '[' .. i .. '].page_id')
        local ext    = json.SelectValue(prefix .. '[' .. i .. '].ext')
        if not isempty(pageId) and not isempty(ext) then
            local pageUrl = cacheUrl .. '/api/v2/books/page/' .. bookId .. '/' ..
                            pageId .. '.' .. ext .. '?token=' .. token
            pages.Add(pageUrl)
        end
    end
end
