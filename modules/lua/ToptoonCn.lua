-- This is the Chinese version of Toptoon (Toptoon.lua).
-- The required selectors are different enough I've moved it to its own module.

function Register()

    module.Name = 'Toptoon'
    module.Type = 'webtoon'
    module.Language = 'cn'

    module.Domains.Add('toptoon.net')
    module.Domains.Add('www.toptoon.net')

end

function GetInfo()

    info.Title = dom.SelectValue('//section[contains(@class,"infoContent")]//div[contains(@class,"title")]')
    info.Author = dom.SelectValue('//div[contains(@class,"etc")]//text()[3]'):after(':')
    info.Summary = dom.SelectValue('//div[contains(@class,"desc")]')

end

function GetChapters()

    local baseUrl = StripParameters(url)
    :replace('/epList/', '/epView/')
    :trim('/') .. '/'

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

function GetPages()

    pages.AddRange(dom.SelectValues('//img[contains(@class,"document_img")]/@data-src'))

end

function Login()

    if(isempty(http.Cookies)) then

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
