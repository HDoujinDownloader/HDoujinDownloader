-- kagane.to.lua
-- HDoujinDownloader module for kagane.to (and kagane.org)
-- API backend: https://kagane.to/api/v2/ (same-origin)
--
-- Auth flow:
--   1. Cloudflare gates the whole domain with a Managed Challenge, handled
--      by HDD's FlareSolverr integration (configure under Tools → FlareSolverr).
--   2. The /books/{id} endpoint additionally requires a short-lived
--      "integrity" token (~5 min TTL) fetched fresh via POST /api/integrity
--      and sent as the X-Integrity-Token header on the next request.
--   3. Page images are served from a separate CDN (kstatic.to) using a
--      short-lived signed token embedded in the /books/{id} response
--      (one token per chapter, shared across all its pages).

function Register()
    module.Name     = 'Kagane'
    module.Language = 'English'
    module.Domains.Add('kagane.to',  'Kagane')
    module.Domains.Add('kagane.org', 'Kagane')

    -- Currently unused by the main auth flow above (which relies on
    -- Cloudflare challenge cookies + the integrity token instead). Left
    -- in place in case a future DRM-gated tier requires a user-supplied
    -- Bearer token; leave blank otherwise.
    module.Settings.AddText('Auth Token', '')
        .WithToolTip(
            'Optional Bearer token. Not required for standard chapters as of ' ..
            'the Aug 2026 API update — leave blank unless told otherwise.'
        )
end

local API_BASE = 'https://kagane.to/api/v2'

-- Cache of already-fetched /series/{id} JSON, keyed by seriesId, so
-- GetInfo() and GetChapters() (which HDD calls back-to-back for the same
-- series) don't each pay for a separate Cloudflare-challenged request.
local _seriesCache = {}

local function SetHeaders()
    http.Headers['Referer'] = 'https://kagane.to/'
    local token = tostring(module.Settings['Auth Token'])
    if not isempty(token) then
        http.Headers['Authorization'] = 'Bearer ' .. token
    else
        http.Headers['Authorization'] = nil
    end
end

local function GetSeriesId()
    return tostring(url):regex('/series/([^/]+)', 1)
end

local function GetBookId()
    return tostring(url):regex('/reader/([^/]+)', 1)
end

-- GET wrapper for /series/{id}, transparently cached per seriesId.
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

-- Fetches a fresh integrity token and attaches it as a header before a
-- protected POST call. Tokens expire in ~5 min, so we always fetch a new
-- one rather than caching — a stale token here would otherwise surface
-- as a confusing 401 on the *next* chapter rather than an obvious failure.
-- If the fetch or parse fails, we explicitly clear any previously-set
-- header rather than silently leaving a stale token in place.
local function SetIntegrityHeader()
    SetHeaders()
    http.Headers['X-Integrity-Token'] = nil

    local resp = http.Post('https://' .. module.Domain .. '/api/integrity', '')
    local json = Json.New(resp)
    local token = json.SelectValue('token')

    if isempty(token) then
        error('Kagane: failed to obtain integrity token (POST /api/integrity did not return one)')
    end

    http.Headers['X-Integrity-Token'] = token
end

-- POST wrapper for endpoints that require the integrity token (currently
-- just /books/{id}). Body is a literal '{}', matching what the real site
-- sends (confirmed via HAR capture — the endpoint 400s on a truly empty body).
local function ApiPost(path)
    SetIntegrityHeader()
    local resp = http.Post(API_BASE .. path, '{}')
    return Json.New(resp)
end

function GetInfo()
    local seriesId = GetSeriesId()
    if isempty(seriesId) then return end
    local json = ApiGetSeries(seriesId)

    info.Title = json.SelectValue('title')

    -- info.Cover and info.AlternateTitles are intentionally not set here:
    -- this HDD build's MangaInfoUserData binding rejects both fields
    -- outright (throws "cannot access field ... of userdata"), so setting
    -- them would crash GetInfo() entirely rather than just losing that data.

    local chapterCount = json.SelectValues('series_books[*].book_id').Count()
    info.PageCount    = chapterCount  -- HDD's "Pages" column
    info.ChapterCount = chapterCount  -- HDD's "Chapters" column; also what
                                      -- enables the "Select Chapters to
                                      -- Download" dialog once non-empty.
    info.Scanlator = 'Kagane'
end

function GetChapters()
    local seriesId = GetSeriesId()
    if isempty(seriesId) then return end
    local json    = ApiGetSeries(seriesId)
    local baseUrl = 'https://' .. module.Domain .. '/series/' .. seriesId .. '/reader/'

    -- SelectElements() errors on this JSON library for arrays of objects
    -- (confirmed via testing), so we pull each field as a flat, index-
    -- aligned list instead and zip them together by position.
    local bookIds = json.SelectValues('series_books[*].book_id')
    local titles  = json.SelectValues('series_books[*].title')
    local sortNos = json.SelectValues('series_books[*].sort_no')

    -- These SelectValues() results are 0-indexed .NET collections, not
    -- 1-indexed Lua tables — confirmed via testing (1-indexed looping
    -- threw ArgumentOutOfRangeException).
    for i = 0, bookIds.Count() - 1 do
        local bookId  = bookIds[i]
        local title   = titles[i]
        local sortNo  = sortNos[i]
        local chapterUrl = baseUrl .. bookId

        local label
        if not isempty(sortNo) then
            label = 'Chapter ' .. sortNo
            if not isempty(title) then
                label = label .. ' - ' .. title
            end
        else
            label = title
        end

        chapters.Add(chapterUrl, label)
    end

    -- No chapters.Reverse() here: series_books[] is already returned in
    -- ascending order by the current API (confirmed via raw JSON dump),
    -- unlike the old API this module originally targeted.
end

function GetPages()
    local seriesId = GetSeriesId()
    local bookId   = GetBookId()
    if isempty(seriesId) or isempty(bookId) then return end

    local json = ApiPost('/books/' .. bookId .. '?is_datasaver=false')

    -- One token covers every page in this chapter (unlike the old API,
    -- which used a separate token per image).
    local token    = json.SelectValue('access_token')
    local cacheUrl = json.SelectValue('cache_url')
    local pageIds  = json.SelectValues('manifest.pages[*].page_id')
    local exts     = json.SelectValues('manifest.pages[*].ext')

    for i = 0, pageIds.Count() - 1 do
        local pageId = pageIds[i]
        local ext    = exts[i]
        if not isempty(pageId) and not isempty(ext) then
            local pageUrl = cacheUrl .. '/api/v2/books/page/' .. bookId .. '/' .. pageId .. '.' .. ext .. '?token=' .. token
            pages.Add(pageUrl)
        end
    end
end