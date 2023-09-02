function Register()

    module.Name = '애니툰'
    module.Language = 'kr'

    module.Domains.Add('anytoon.co.kr')
    module.Domains.Add('www.anytoon.co.kr')

end

function GetInfo()

    info.Title = dom.SelectValue('//div[contains(@class,"episode-title")]//div[contains(@class,"title")]')
    info.Author = dom.SelectValue('//span[contains(@class,"tag-writer")]')
    info.Tags = dom.SelectValues('//span[contains(@class,"tag-genre")]')
    info.Summary = dom.SelectValue('//div[contains(@class,"synopsis")]')

end

function GetChapters()

    for episodeNode in dom.SelectElements('//ul[contains(@id,"episode_list")]//li') do
        
        -- https://www.anytoon.co.kr/webtoon/view/8116/202487?IS_FREE=N

        local episodeTitle = episodeNode.SelectValue('.//p[contains(@class,"main-title")]')
        local episodeUrl = episodeNode.SelectValue('.//@href')
        local webtoonId = episodeUrl:regex("checkView\\(.+?'(\\d+)',\\s*'(\\d+)'", 1)
        local episodeId = episodeUrl:regex("checkView\\(.+?'(\\d+)',\\s*'(\\d+)'", 2)

        episodeUrl = '/webtoon/view/' .. webtoonId .. '/' .. episodeId

        chapters.Add(episodeUrl, episodeTitle)

    end

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@id,"view_webtoon")]//img/@src'))

end

function Login()

    if(isempty(http.Cookies)) then

        -- We need to get a session cookie before making a login request.

        http.Get('https://' .. module.Domain .. '/')

        http.Headers['accept'] = '*/*'
        http.Headers['content-type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
        http.Headers['referer'] = 'https://' .. module.Domain .. '/'
        http.Headers['x-requested-with'] = 'XMLHttpRequest'

        local loginEndpoint = 'https://' .. module.Domain .. '/user/login.json'

        -- "DUPL_KEY" is a 10-character, randomly-generated string returned by "getDuplChk" in "common_script.js".
        
        local js = JavaScript.New()

        js.Execute('function getDuplChk(){for(var r="1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",n=r.length-1,o="",t=0;t<10;t++)o+=r.substr(Math.floor(Math.random()*n),1);return o}')

        local duplKey = tostring(js.Execute('getDuplChk()'))

        http.PostData.Add('USER_ID', username)
        http.PostData.Add('PW', password)
        http.PostData.Add('DUPL_KEY', duplKey)

        local response = http.PostResponse(loginEndpoint)

        global.SetCookies(response.Cookies)

    end

end
