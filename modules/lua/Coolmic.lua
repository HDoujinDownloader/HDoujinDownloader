function Register()

    module.Name = 'Coolmic'
    module.Language = 'English'
    module.Adult = true

    module.Domains.Add('coolmic.me')

    -- The following cookie(s) are required to access mature content.

    global.SetCookie(module.Domain, 'is_mature', 'true')

end

local function DetectLoginRequired()

    local js = JavaScript.New()

    js.Execute('window = {}')
    js.Execute(dom.SelectValue('//script[contains(text(),"is_login")]'))

    return tostring(Json.New(js.Execute('JSON.stringify(window.is_login)'))) == 'false' and dom.SelectElement('//div[@id="v-episodes-show"]').Count() == 0
    
end

local function GetJsonEpisodeObject()

    local episodeObject = dom.SelectValue("//@*[local-name()=':episode-object']")

    return Json.New(episodeObject:replace('&quot;', '\"'))

end

local function GetJsonPageObjects()

    local pageObjects = dom.SelectValue("//@*[local-name()=':page-objects']")

    return Json.New(pageObjects:replace('&quot;', '\"'))

end

local function GetApiUrl()

    return '//' .. module.Domain .. '/api/v1/viewer/episodes/'

end

local function GetApiJson(id)

    http.Headers['Accept'] = 'application/json, text/plain, */*'

    return Json.New(http.Get(GetApiUrl() .. id))

end

local function GetChapterId()

    local episodeJson = GetJsonEpisodeObject().SelectToken('episode')

    return episodeJson.SelectValue('id')

end

function GetInfo()

    local json = GetJsonPageObjects().SelectToken('title')

    info.Title = json.SelectValue('name')
    info.Summary = json.SelectValue('summary')
    info.Artist = json.SelectValues('artists[*].name')
    info.Publisher = json.SelectValue('agency')
    info.Tags = json.SelectValues('tags[*].name')

    if(isempty(info.Tags)) then
        info.Tags = json.SelectValues('genres[*].name')
    end

    if (json.SelectValues('is_completed'):contains('true')) then
        info.Status = 'completed'
    else
        info.Status = 'ongoing'
    end

end

function GetChapters()
    
    local json = GetJsonPageObjects()

    for chapterJson in json.SelectTokens('episodes[*]') do

        local chapterUrl = GetRoot(url) .. 'episodes/' .. chapterJson.SelectValue('id')
        local chapterTitle = ''

        if (chapterJson.SelectValue('name') == json.SelectToken('title').SelectValue('name')) then
            chapterTitle = 'Chapter ' .. chapterJson.SelectValue('number')
        else
            chapterTitle = 'Chapter ' .. ' - ' .. chapterJson.SelectValue('name')
        end

        if(chapterJson.SelectValue('is_free'):contains('true')) then

            -- Get Free Chapters

            chapters.Add(chapterUrl, chapterTitle)

        end

        if(chapterJson.SelectValue('is_free'):contains('false') and json.SelectToken('user').SelectValue('is_login'):contains('true')) then

            -- Get Paid Chapters

            chapters.Add(chapterUrl, chapterTitle)

        end

    end

    -- Default Reverse

    -- chapters.Reverse()

end

function GetPages()

    -- Check if need to log in.

    if(DetectLoginRequired()) then

        Fail(Error.LoginRequired)

    end

    local json = GetApiJson(GetChapterId())

    local signedCookies = json.SelectToken('signed_cookie')
    local policy = signedCookies.SelectValue('CloudFront-Policy')
    local signature = signedCookies.SelectValue('CloudFront-Signature')
    local keyPairId = signedCookies.SelectValue('CloudFront-Key-Pair-Id')

    for pageUrl in json.SelectValues('image_data[*].path') do

        pageUrl = pageUrl .. '?Policy=' .. policy .. '&Signature=' .. signature .. '&Key-Pair-Id=' .. keyPairId

        pages.Add(pageUrl)
        
    end

end

function Login()

    local loginCookieName = 'remember_me_token'

    if(not http.Cookies.Contains(loginCookieName)) then
    
        http.Referer = 'https://'..module.Domain

        local dom = Dom.New(http.Get('https://' .. module.Domain .. '/login'))

        http.PostData.Add('authenticity_token', dom.SelectValue('//meta[@name="csrf-token"]/@content'))
        http.PostData.Add('recaptcha_token', '')
        http.PostData.Add('email', username)
        http.PostData.Add('password', password)
        http.PostData.Add('remember', true)

        local response = http.PostResponse('https://' .. module.Domain .. '/user/sessions')
    
        if(not response.Cookies.Contains(loginCookieName)) then
            Fail(Error.LoginFailed)
        end
    
        global.SetCookies(response.Cookies)
    
    end

end
