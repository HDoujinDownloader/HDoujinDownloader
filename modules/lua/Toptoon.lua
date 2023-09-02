function Register()

    module.Name = 'Toptoon'
    module.Type = 'webtoon'
    module.Language = 'ko'

    module.Domains.Add('toptoon.com')

end

function GetInfo()
  
    info.Title = dom.SelectValue('//span[@title]')
    info.Author = dom.SelectValue('//span[contains(@class,"comic_wt")]')
    info.Summary = dom.SelectValue('//p[contains(@class,"story_synop")]')

end

function GetChapters()

    local baseUrl = StripParameters(url)
    :replace('/ep_list/', '/ep_view/')
    :trim('/') .. '/'

    for episodeNode in dom.SelectElements('//a[@data-episode-id]') do

        local episodeUrl = baseUrl .. episodeNode.SelectValue('@data-episode-id')
        local episodeTitle = episodeNode.SelectValue('.//p[contains(@class,"episode_title")]')
        local episodeSubtitle = episodeNode.SelectValue('.//p[contains(@class,"episode_stitle")]')

        if(not isempty(episodeSubtitle)) then
            episodeTitle = episodeTitle .. episodeSubtitle
        end

        chapters.Add(episodeUrl, episodeTitle)

    end
    
end

function GetPages()

    pages.AddRange(dom.SelectValues('//img[contains(@class,"document_img")]/@data-src'))

end

function Login()

    if(isempty(http.Cookies)) then

        local sourcePage = 'https://' .. module.Domain .. '/'

        -- Get a session cookie.

        http.Get(sourcePage)

        -- Get the login form so we can get a login token.

        local dom = Dom.New(http.Get('https://' .. module.Domain .. '/alert/auth/login?no-token=yes&redirect=https%253A%252F%252F' .. module.Domain .. '%252F'))
        local token = dom.SelectValue('//script[contains(text(), "Login.init")]'):regex("token\\s*:\\s*'([^']+)", 1)

        -- Make the login request.

        http.Headers['accept'] = 'application/json, text/javascript, */*; q=0.01'
        http.Headers['content-type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
        http.Headers['referer'] = sourcePage
        http.Headers['x-requested-with'] = 'XMLHttpRequest'

        local loginEndpoint = '/login/login_proc'

        http.PostData.Add('user_id', username)
        http.PostData.Add('user_pw', password)
        http.PostData.Add('id_save', '1')
        http.PostData.Add('auto_login', '1')
        http.PostData.Add('tokn', token)
        http.PostData.Add('ci_token', 'null')

        local response = http.PostResponse(loginEndpoint)

        global.SetCookies(response.Cookies) 

    end

end
