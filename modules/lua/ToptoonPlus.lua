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

    if(isempty(pages)) then
       
        -- The episode is only available as WebP.

        pages.AddRange(json.SelectValues("data.episode[*].contentImage.webp[*].path"))
        
    end

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

function GetApiUrl(path)

    local baseUrl = 'https://api.' ..  module.Domain .. '/api/'
    local result = baseUrl

    if(not isempty(path)) then

        -- Take a relative API path and convert it to a full path

        if(not path:startsWith('//') and not path:startsWith('https://')) then
            result = baseUrl .. path
        else
            result = path
        end

    end

    return result

end

function SetUpApiHeaders(version)

    version = isempty(version) and 'v1' or version

    if(version == 'v1') then

        http.Headers['is17'] = 'false'
        http.Headers['isalreadymature'] = '1'
        http.Headers['partnercode'] = 'subred'
        http.Headers['referer'] = 'https://' .. module.Domain
        http.Headers['x-api-key'] = 'SUPERCOOLAPIKEY2021#@#('

    elseif(version == 'v2') then

        -- Add API v2 headers "timestamp" and "x-api-key".

        -- The API key is generated in the 'convertApiKey' function from the device ID and timestamp.

        local js = JavaScript.New()

        local timestamp = tostring(js.Execute('Date.now()'))

        js.Execute(http.Get('https://cdnjs.cloudflare.com/ajax/libs/crypto-js/4.0.0/crypto-js.min.js'))

        -- Set up the variables used to generate the API key.

        js.Execute('e = ' .. timestamp);
        js.Execute('t = "' .. GetDeviceId() .. '"');
        js.Execute('n = 257'); -- REACT_APP_API_KEY_ITERATION

        local apiKey = tostring(js.Execute('i=CryptoJS.SHA256(t.toString().replace(/-/g,"".concat(e))).toString(CryptoJS.enc.Hex);CryptoJS.PBKDF2("".concat(t,"|").concat(e),i,{hasher:CryptoJS.algo.SHA512,keySize:i.length / 4,iterations:n}).toString(CryptoJS.enc.Base64)'))

        http.Headers['timestamp'] = timestamp
        http.Headers['x-api-key'] = apiKey

    end

    http.Headers['accept'] = '*/*'
    http.Headers['deviceId'] = GetDeviceId()
    http.Headers['language'] = 'en'
    http.Headers['origin'] = 'https://' .. module.Domain
    http.Headers['ua'] = 'web'
    http.Headers['version'] = 'undefined'
    http.Headers['x-origin'] = module.Domain

    local token = GetToken()

    if(not isempty(token)) then
        http.Headers['token'] = token
    end

end

function GetComicId()

    -- toptoonplus.com/comic/<comic_id>/
    -- toptoonplus.com/content/<title>/<comic_id>
    
    return url:regex('(?:content\\/[^\\/]+|\\/comic)\\/(\\d+)', 1)

end

function GetEpisodeId()

    -- toptoonplus.com/comic/<comic_id>/<episode_id>
    -- toptoonplus.com/content/<title>/<comic_id>/<episode_id>

    return url:regex('(?:content\\/[^\\/]+|\\/comic)\\/\\d+\\/(\\d+)', 1)

end

function GetComicJson()

    SetUpApiHeaders()

    local endpoint = GetApiUrl('v1/page/episode?comicId=' .. GetComicId())
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

    local endpoint = GetApiUrl('//api.toptoonplus.com/check/isUsableEpisode?comicId=' .. comicId .. '&episodeId=' .. episodeId .. '&location=viewer&action=view_contents')
    local json = Json.New(http.Get(endpoint))

    viewerToken = json.SelectValue('data.viewerToken')

    -- Get the episode images.

    SetUpApiHeaders('v2')

    http.Headers['content-type'] = 'application/json'
    
    endpoint = GetApiUrl('v2/viewer/' .. comicId .. '/' .. episodeId, 'v2')

    local payload = '{"location":"viewer","action":"view_contents","isCached":false,"viewerToken":"' .. viewerToken .. '","cToken":""}'
    local json = Json.New(http.Post(endpoint, payload))

    return Json.New(json)

end
