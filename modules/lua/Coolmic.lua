function Register()

    module.Name = 'Coolmic'
    module.Language = 'English'
    module.Adult = true

    module.Domains.Add('coolmic.me')

    -- The following cookie(s) are required to access mature content.

    global.SetCookie(module.Domain, 'is_mature', 'true')

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

    global.SetCookie('.' .. module.Domains.First(), "CloudFront-Policy", signedCookies.SelectValue('CloudFront-Policy'))
    global.SetCookie('.' .. module.Domains.First(), "CloudFront-Signature", signedCookies.SelectValue('CloudFront-Signature'))
    global.SetCookie('.' .. module.Domains.First(), "CloudFront-Key-Pair-Id", signedCookies.SelectValue('CloudFront-Key-Pair-Id'))

    for pageJson in json.SelectTokens('image_data[*]') do

        pages.Add(pageJson.SelectValue('path'))
        
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

function DetectLoginRequired()

    local js = JavaScript.New()

    js.Execute('window = {}')
    js.Execute(dom.SelectValue('//script[contains(text(),"is_login")]'))

    return tostring(Json.New(js.Execute('JSON.stringify(window.is_login)'))) == 'false' and dom.SelectElement('//div[@id="v-episodes-show"]').Count() == 0
    
end

function GetJsonEpisodeObject()

    local episode_object = tostring(dom):regex(':episode-object="(.*}})"', 1)

    return Json.New(episode_object:replace('&quot;', '\"'))

end

function GetJsonPageObjects()

    local page_objects = tostring(dom):regex(':page-objects="(.*}})"', 1)

    return Json.New(page_objects:replace('&quot;', '\"'))

end

function GetApiUrl()

    return '//' .. module.Domain .. '/api/v1/viewer/episodes/'

end

function GetApiJson(id)

    http.Headers['accept'] = 'application/json, text/plain, */*'
    

    return Json.New(http.Get(GetApiUrl() .. id))

end

function GetChapterId()

    local episodeJson = GetJsonEpisodeObject().SelectToken('episode')

    return episodeJson.SelectValue('id')

end
