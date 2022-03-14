function Register()

    module.Name = 'TOPTOON PLUS'
    module.Type = 'Webtoon'

    module.Domains.Add('toptoonplus.com')

    module.Settings.AddText('Token', '')

    global.SetCookie(module.Domains.First(), 'already_mature', '1')

end

function GetInfo()

    local json = GetComicJson()

    info.Title = json.SelectValue('data.comic.information.title')
    info.Summary = json.SelectValue('data.comic.information.description')
    info.Author = json.SelectValues('data.comic.author[*]')

end

function GetChapters()

    local json = GetComicJson()

    for node in json.SelectTokens('data.episode[*]') do

        local episodeId = node.SelectValue('episodeId')
        local comicId = node.SelectValue('comicId')
        local chapterUrl = '/comic/' .. comicId .. '/' .. episodeId
        local chapterTitle = node.SelectValue('information.title')
        local chapterSubtitle = node.SelectValue('information.subTitle')

        if(not isempty(chapterSubtitle)) then
            chapterTitle = chapterTitle .. ' - ' .. chapterSubtitle
        end

        chapters.Add(chapterUrl, chapterTitle)

    end

end

function GetPages()

    local json = GetEpisodeJson()
    local episodeId = GetEpisodeId()

    pages.AddRange(json.SelectValues("data.episode[*].contentImage.jpeg[*].path"))

end

function Login()

    local token = GetToken()

    if(isempty(token)) then
        
        local loginEndpoint = '//api.toptoonplus.com/auth/generateToken'

        SetUpApiHeaders()

        http.PostData['auth'] = '0'
        http.PostData['deviceId'] = GetDeviceId()
        http.PostData['is17'] = 'false'
        http.PostData['password'] = password
        http.PostData['userId'] = username

        local json = Json.New(http.Post(loginEndpoint))

        token = json.SelectValue('data.token')

        module.Data['token'] = token

        if(isempty(token)) then
            Fail(Error.LoginFailed)
        end

    end

end

function GetDeviceId()

    return 'a9d4f080-4aa0-11ec-81d3-0242ac130003'

end

function GetToken()

    if(not isempty(module.Data['token'])) then
        return module.Data['token']
    elseif(not isempty(module.Settings['Token'])) then
        return module.Settings['Token']
    end

    return ''

end

function GetApiUrl()

    -- Return the base API path

    return 'https://api.' ..  module.Domain .. '/api/v1/'

end

function SetUpApiUrl(path)

    -- Take a relative API path and convert it to a full path

    if(not path:startsWith('//') and not path:startsWith('https://')) then
        path = GetApiUrl() .. path
    end

    return path

end

function SetUpApiHeaders()

    http.Headers['accept'] = '*/*'
    http.Headers['deviceId'] = GetDeviceId()
    http.Headers['is17'] = 'false'
    http.Headers['isalreadymature'] = '1'
    http.Headers['language'] = 'en'
    http.Headers['partnercode'] = ''
    http.Headers['ua'] = 'web'
    http.Headers['version'] = '1.15.1647223446b'
    http.Headers['x-api-key'] = 'SUPERCOOLAPIKEY2021#@#('
    http.Headers['origin'] = 'https://toptoonplus.com'
    http.Headers['referer'] = 'https://toptoonplus.com/'

    local token = GetToken()

    if(not isempty(token)) then
        http.Headers['token'] = token
    end

end

function GetComicId()

    return url:regex('\\/comic\\/(\\d+)', 1)

end

function GetEpisodeId()

    return url:regex('\\/comic\\/\\d+\\/(\\d+)', 1)

end

function GetComicJson()

    SetUpApiHeaders()

    local endpoint = SetUpApiUrl('page/episode?comicId=' .. GetComicId())
    local json = Json.New(http.Get(endpoint))

    return Json.New(json)

end

function GetEpisodeJson()

    SetUpApiHeaders()

    local cToken = ''
    local comicId = GetComicId()
    local episodeId = GetEpisodeId()
    local viewerToken = ''

    -- Start by getting the episode metadata, which includes the viewer token.
    -- The viewer token is needed for episodes that require an account, and is only valid when logged in (valid "token" header sent with the request).

    local endpoint = SetUpApiUrl('//api.toptoonplus.com/check/isUsableEpisode?comicId=' .. comicId .. '&episodeId=' .. episodeId .. '&location=viewer&action=view_contents')
    local json = Json.New(http.Get(endpoint))

    viewerToken = json.SelectValue('data.viewerToken')

    -- Get the episode images.

    http.Headers['content-type'] = 'application/json'
    
    endpoint = SetUpApiUrl('page/viewer')
    local payload = '{"comicId":' .. comicId .. ',"episodeId":' .. episodeId .. ',"viewerToken":"' .. viewerToken .. '","cToken":"' .. cToken .. '"}'
    local json = Json.New(http.Post(endpoint, payload))

    return Json.New(json)

end
