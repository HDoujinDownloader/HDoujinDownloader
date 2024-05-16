function Register()

    module.Name = 'Webnovel'
    module.Language = 'en'

    module.Domains.Add('webnovel.com')
    module.Domains.Add('www.webnovel.com')

end

local function GetComicId()

    -- From reader

    local comicId = dom.SelectValue('//script[contains(text(),"g_data.comicId")]')
        :regex('g_data\\.comicId\\s*=\\s*"([^"]+)', 1)

    -- From gallery

    if(isempty(comicId)) then
        comicId = url:regex('_(\\d+)$', 1)
    end

    return comicId

end

local function GetEpisodeId()

    return dom.SelectValue('//script[contains(text(),"g_data.chapterId")]')
        :regex('g_data\\.chapterId\\s*=\\s*"([^"]+)', 1)

end

local function GetApiUrl()

    return '//www.' .. GetDomain(module.Domain) .. '/go/pcm/comic/'

end

local function SetUpApiHeaders()

    http.Headers['accept'] = 'application/json, text/javascript, */*; q=0.01'
    http.Headers['x-requested-with'] = 'XMLHttpRequest'

end

local function GetCsrfToken()
   
    -- Get the CSRF token, which is returned as a cookie.

    local csrfToken = http.Cookies['_csrfToken']

    if(isempty(csrfToken)) then

        dom  = Dom.New(http.Get(url))

        csrfToken = http.Cookies['_csrfToken']

    end

    return csrfToken

end

local function GetApiJson(path)

    SetUpApiHeaders()

    local endpoint = GetApiUrl() .. path
    local json = Json.New(http.Get(endpoint))

    return json

end

local function GetComicJson(path)

    local comicId = GetComicId()

    local endpoint = path .. '?_csrfToken=' .. GetCsrfToken() .. '&comicId=' .. GetComicId() .. '&_=0'
    local json = GetApiJson(endpoint)

    return json

end

local function GetEpisodeJson()

    local endpoint = 'getContent?_csrfToken=' .. GetCsrfToken() .. '&chapterId=' .. GetEpisodeId() .. '&comicId=' .. GetComicId()
    local json = GetApiJson(endpoint)

    return json

end

function GetInfo()

    local json = GetComicJson('getContent')

    info.Title = json.SelectValue('data.comicInfo.comicName')
    info.Language = json.SelectValue('data.comicInfo.languageName')
    info.Publisher = json.SelectValue('data.comicInfo.publisher')

end

function GetChapters()

    local json = GetComicJson('getChapterList')
    local baseUrl = StripParameters(url):trim('/')

    for episodeNode in json.SelectTokens('data.comicChapters[*]') do

        local chapterId = episodeNode.SelectValue('chapterId')
        local chapterNumber = episodeNode.SelectValue('chapterIndex')
        local chapterName = episodeNode.SelectValue('chapterName')
        local chapterTitle = chapterNumber .. ' - ' .. chapterName
        local chapterUrl = baseUrl .. '/' .. chapterTitle:lower():replace(' ', '-') .. '_' .. chapterId

        chapters.Add(chapterUrl, chapterTitle)

    end

end

function GetPages()

    local json = GetEpisodeJson()

    pages.AddRange(json.SelectValues('data.chapterInfo.chapterPage[*].url'))

end
