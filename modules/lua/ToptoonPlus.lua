function Register()

    module.Name = 'TOPTOON PLUS'
    module.Type = 'Webtoon'

    module.Domains.Add('daycomics.com')
    module.Domains.Add('toptoonplus.com')

    -- The device ID is not strictly required to authenticate with the user's token, and it doesn't matter if it doesn't match.
    -- However, a valid "user-id" header must be included with all requests that use the token, or the server will invalidate the token.

    module.Settings.AddText('User ID', '')
    module.Settings.AddText('Token', '')
    module.Settings.AddText('Device ID', '')

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
        local chapterUrl = '/content/' .. comicId .. '/' .. episodeId
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

    pages.AddRange(json.SelectValues("data.episode[*].contentImage.jpeg[*].path"))

    if(isempty(pages)) then
       
        -- The episode is only available as WebP.

        pages.AddRange(json.SelectValues("data.episode[*].contentImage.webp[*].path"))
        
    end

end

function Login()

    local token = GetToken()

    if(isempty(token)) then
        
        local loginEndpoint = GetApiUrl('auth/generateToken')

        SetUpApiHeaders('v2')

        http.Headers['pathname'] = '/'

        local payload = '{"userId":"' .. username .. '","password":"' .. password .. '","auth":0,"is17":false,"deviceId":"' .. GetDeviceId() .. '","cToken":""}'
        local json = Json.New(http.Post(loginEndpoint, payload))

        token = json.SelectValue('data.token')

        module.Data['token'] = token

        if(isempty(token)) then
            Fail(Error.LoginFailed)
        end

    end

end

function GetDeviceId()

    -- Generate a device UUID, but be a little random about it.
    -- Some users were having problems resulting from a static UUID (too many concurrent users?).

    if(not isempty(module.Settings['Device ID'])) then

        -- If the user has manually specified a device ID, use it.

        return module.Settings['Device ID']

    elseif(isempty(module.Data['Device ID'])) then

        -- If the user has not specified a device ID, generate one.
        -- We will continue using the same device ID for subsequent requests.

        math.randomseed(os.time())

        module.Data['Device ID'] = math.random(1, 9) .. 'b6b034-8a1a-4c39-b814-6bbb27aead1d'

    end

    return module.Data['Device ID']

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

        if(path:startswith('/')) then

            path = path:sub(2)

        end

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

    local js = JavaScript.New()
    local token = GetToken()

    http.Headers['accept'] = '*/*'
    http.Headers['deviceId'] = GetDeviceId()
    http.Headers['language'] = 'en'
    http.Headers['local-datetime'] = tostring(js.Execute("(function() { var date = new Date(); return date.getFullYear() + '-' + String(date.getMonth() + 1).padStart(2, '0') + '-' + String(date.getDate()).padStart(2, '0') + ' ' + String(date.getHours()).padStart(2, '0') + ':' + String(date.getMinutes()).padStart(2, '0') + ':' + String(date.getSeconds()).padStart(2, '0'); })()"))
    http.Headers['origin'] = 'https://' .. module.Domain
    http.Headers['package-name'] = 'web'
    http.Headers['pathname'] = url and url:after(module.Domain) or '/'
    http.Headers['referer'] = 'https://' .. module.Domain .. '/'
    http.Headers['timestamp'] = tostring(js.Execute('Date.now()'))
    http.Headers['timezone'] = 'America/California'
    http.Headers['ua'] = 'web'
    http.Headers['user-id'] = module.Settings['User ID'] or '0'
    http.Headers['version'] = '0.1.5a'
    http.Headers['x-api-key'] = 'SUPERCOOLAPIKEY2021#@#('
    http.Headers['x-origin'] = module.Domain

    if(version == 'v2') then

        -- Add API v2 headers "timestamp" and "x-api-key".
        -- The API key is generated in the 'convertApiKey' function from the device ID and timestamp.

        js.Execute(http.Get('https://cdnjs.cloudflare.com/ajax/libs/crypto-js/4.0.0/crypto-js.min.js'))

        -- Set up the variables used to generate the API key.

        js.Execute('e = ' .. http.Headers['timestamp']);
        js.Execute('t = "' .. http.Headers['deviceId'] .. '"');
        js.Execute('n = 257'); -- REACT_APP_API_KEY_ITERATION

        local apiKey = tostring(js.Execute('i=CryptoJS.SHA256(t.toString().replace(/-/g,"".concat(e))).toString(CryptoJS.enc.Hex);CryptoJS.PBKDF2("".concat(t,"|").concat(e),i,{hasher:CryptoJS.algo.SHA512,keySize:i.length / 4,iterations:n}).toString(CryptoJS.enc.Base64)'))

        http.Headers['content-type'] = 'application/json'
        http.Headers['x-api-key'] = apiKey

        if(not isempty(token)) then
            http.Headers['token'] = token
        end

    end

end

function GetComicId()

    -- toptoonplus.com/comic/<comic_id>/
    -- toptoonplus.com/content/<title>/<comic_id>
    -- daycomics.com/content/<comic_id>
    
    return url:regex('\\/(?:comic|content\\/[^\\d]+|content)\\/(\\d+)', 1)

end

function GetEpisodeId()

    -- toptoonplus.com/comic/<comic_id>/<episode_id>
    -- toptoonplus.com/content/<title>/<comic_id>/<episode_id>
    -- daycomics.com/content/<comic_id>/<episode_id>

    return url:regex('\\/(?:comic|content\\/[^\\d]+|content)\\/\\d+\\/(\\d+)', 1)

end

function GetComicJson()

    SetUpApiHeaders()

    local endpoint = GetApiUrl('v1/page/episode?comicId=' .. GetComicId())
    local json = Json.New(http.Get(endpoint))

    return Json.New(json)

end

function GetEpisodeJson()

    SetUpApiHeaders()

    local comicId = GetComicId()
    local episodeId = GetEpisodeId()

    -- Get the episode images.

    SetUpApiHeaders('v2')

    local endpoint = GetApiUrl('v2/viewer/' .. comicId .. '/' .. episodeId)
    local payload = '{"location":"viewer","action":"view_contents","isCached":false,"cToken":""}'
    local json = Json.New(http.Post(endpoint, payload))

    return Json.New(json)

end
