function Register()

    module.Name = 'Toptoon'
    module.Type = 'webtoon'

    module = Module.New()

    module.Language = 'ko'

    module.Domains.Add('toptoon.com')

    RegisterModule(module)

    module = Module.New()

    module.Language = 'cn'

    module.Domains.Add('toptoon.net')
    module.Domains.Add('www.toptoon.net')

    RegisterModule(module)

end

function GetInfo()
  
    if(GetDomain() == 'toptoon.com') then
        
        info.Title = dom.SelectValue('//span[@title]')
        info.Author = dom.SelectValue('//span[contains(@class,"comic_wt")]')
        info.Summary = dom.SelectValue('//p[contains(@class,"story_synop")]')

    else

        info.Title = dom.SelectValue('//section[contains(@class,"infoContent")]//div[contains(@class,"title")]')
        info.Author = dom.SelectValue('//div[contains(@class,"etc")]//text()[3]'):after(':')
        info.Summary = dom.SelectValue('//div[contains(@class,"desc")]')

    end

end

function GetChapters()

    local baseUrl = StripParameters(url)
    :replace('/ep_list/', '/ep_view/')
    :replace('/epList/', '/epView/')
    :trim('/') .. '/'

    if(GetDomain() == 'toptoon.com') then

        for episodeNode in dom.SelectElements('//a[@data-episode-id]') do

            local episodeUrl = baseUrl .. episodeNode.SelectValue('@data-episode-id')
            local episodeTitle = episodeNode.SelectValue('.//p[contains(@class,"episode_title")]')
            local episodeSubtitle = episodeNode.SelectValue('.//p[contains(@class,"episode_stitle")]')
    
            if(not isempty(episodeSubtitle)) then
                episodeTitle = episodeTitle .. episodeSubtitle
            end
    
            chapters.Add(episodeUrl, episodeTitle)
    
        end

    else

        for episodeNode in dom.SelectElements('//li[contains(@class,"episodeBox")]') do
            
            local episodeUrl = baseUrl .. episodeNode.SelectValue('.//@data-episode_idx')
            local episodeTitle = episodeNode.SelectValue('.//div[contains(@class,"title")]/text()[1]')
            local episodeSubtitle = episodeNode.SelectValue('.//div[contains(@class,"subTitle")]/text()[1]')

            if(not isempty(episodeSubtitle)) then
                episodeTitle = episodeTitle .. episodeSubtitle
            end
    
            chapters.Add(episodeUrl, episodeTitle)

        end

    end
    
end

function GetPages()

    pages.AddRange(dom.SelectValues('//img[contains(@class,"document_img")]/@data-src'))

end

function Login()

    if(GetDomain() == 'toptoon.com') then

            -- Login is currently only implemented for toptoon.net.

            Fail(Error.LoginFailed)

    else

        http.Headers['accept'] = 'application/json, text/javascript, */*; q=0.01'
        http.Headers['content-type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
        http.Headers['referer'] = 'https://' .. module.Domain .. '/'
        http.Headers['x-requested-with'] = 'XMLHttpRequest'

        local loginEndpoint = '/member/login_proc'

        http.PostData.Add('redirect', http.Headers['referer'])
        http.PostData.Add('userId', username)
        http.PostData.Add('userPw', password)
        http.PostData.Add('saveId', '1')
        http.PostData.Add('autoLogin', '1')

        local response = http.PostResponse(loginEndpoint)

        if(not response.Cookies.Contains('isLoginUsed')) then
            Fail(Error.LoginFailed)
        end

        global.SetCookies(response.Cookies)

    end

end
