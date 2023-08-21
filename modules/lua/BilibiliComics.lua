function Register()

    module.Name = 'BILIBILI COMICS'

    module.Domains.Add('bilibilicomics.com')
    module.Domains.Add('www.bilibilicomics.com')

    module.Settings.AddText('Bearer token', '')

end

function GetInfo()

    local json = GetComicJson()

    info.Title = json.SelectValue('data.title')
    info.Author = json.SelectValues('data.author_name[*]')
    info.Summary = json.SelectValue('data.evaluate')

end

function GetChapters()

    local json = GetComicJson()

    local comicId = GetComicId()

    for episodeNode in json.SelectTokens('data.ep_list[*]') do

        local episodeId = episodeNode.SelectValue('id')
        local episodeUrl = '/mc' .. comicId .. '/' .. episodeId .. '?from=manga_detail'
        local episodeNumber = episodeNode.SelectValue('short_title')
        local episodeTitle = episodeNumber .. ' ' .. episodeNode.SelectValue('title')

        chapters.Add(episodeUrl, episodeTitle)

    end

    chapters.Reverse()

end

function GetPages()

    local json = GetEpisodeJson()

    local imageHost = json.SelectValue('data.host')

    for imageUrl in json.SelectValues('data.images[*].path') do
        pages.Add(imageHost .. imageUrl)
    end

end

function BeforeDownloadPage()

    if(page.Url:contains('?token=')) then
        return
    end

    local json = GetImageJson(page.Url)
    local url = json.SelectValue('data[*].url')
    local token = json.SelectValue('data[*].token')

    page.Url = url .. '?token=' .. token

end

function GetComicId()

    return url:regex('\\/mc(\\d+)', 1)

end

local function GetEpisodeId()

    return url:regex('\\/mc\\d+\\/(\\d+)', 1)

end

local function GetApiUrl()

    return '//www.bilibilicomics.com/twirp/comic.v1.Comic/'

end

local function GetBearerToken()

    local bearerToken = module.Settings['Bearer token']

    if(not isempty(bearerToken)) then

        if(not bearerToken:startswith('Bearer ')) then
            bearerToken = 'Bearer ' .. bearerToken
        end

    end

    return bearerToken

end

local function SetUpApiHeaders()

    http.Headers['accept'] = '*/*'
    http.Headers['content-type'] = 'application/json;charset=UTF-8'

    local bearerToken = GetBearerToken()

    if(not isempty(bearerToken)) then
        http.Headers['authorization'] = bearerToken
    end

end

local function GetApiJson(endpoint, payload)

    SetUpApiHeaders()

    local json = Json.New(http.Post(endpoint, payload))

    return json

end

function GetComicJson()

    local endpoint = GetApiUrl() .. 'ComicDetail?device=pc&platform=web&lang=en&sys_lang=en'
    local payload = '{"comic_id":' .. GetComicId() .. '}'

    return GetApiJson(endpoint, payload)

end

function GetEpisodeJson()

    local endpoint = GetApiUrl() .. 'GetImageIndex?device=pc&platform=web&lang=en&sys_lang=en'
    local comicId = GetComicId()
    local episodeId = GetEpisodeId()
    local payload = '{"ep_id":' .. episodeId .. ',"credential":""}'
    local json = GetApiJson(endpoint, payload)

    if(json.SelectValue('code') == '1') then

        -- We need to supply a credential in order to access all of the images for this episode.
        -- Otherwise, we're only able to download the first two images.

        local credentialEndpoint = '/twirp/global.v1.Comic/GetCredential?device=pc&platform=web&lang=en&sys_lang=en'
        local credentialPayload = '{"type":1,"comic_id":' .. comicId .. ',"ep_id":' .. episodeId .. '}'
        local credentialJson = GetApiJson(credentialEndpoint, credentialPayload)
        local credential = credentialJson.SelectValue('data.credential')

        if(not isempty(credential)) then

            payload = '{"ep_id":' .. episodeId .. ',"credential":"' .. credential .. '"}'
            json = GetApiJson(endpoint, payload)

        end

    end

    return json

end

function GetImageJson(url)

    -- Get the relative URL.

    url = '/' .. url:after('//'):after('/')

    local imageFormat = '2000w.webp'
    local endpoint = GetApiUrl() .. 'ImageToken?device=pc&platform=web&lang=en&sys_lang=en'
    local payload = '{"urls":"[\\"' .. url .. '@' .. imageFormat .. '\\"]"}'

    return GetApiJson(endpoint, payload)

end
