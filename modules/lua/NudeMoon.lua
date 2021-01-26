function Register()

    module.Name = 'Nude-Moon!'
    module.Language = 'Russian'
    module.Adult = true
    module.Strict = false

    module.Domains.Add('nude-moon.com')
    module.Domains.Add('nude-moon.me')
    module.Domains.Add('nude-moon.net')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1'):beforelast('/') 
    info.Tags = dom.SelectValues('//span[contains(@class,"tag-links")]//a')
    info.Author = dom.SelectValues('//div[contains(text(),"Автор:")]/a[contains(@href,"mangaka/")]')
    info.Circle = dom.SelectValues('//div[contains(text()," Группа/цикл:")]/a[contains(@href,"group/")]')
    info.PageCount = tostring(dom):regex('Страниц:\\s*(\\d+)', 1)

    -- Get the reader URL if we're on the summary page.

    local readerUrl = dom.SelectValue('//a[contains(text(),"ЧИТАТЬ ДАЛЕЕ")]/@href')

    if(not isempty(readerUrl)) then
        info.Url = readerUrl
    end

end

function GetPages()

    for match in RegexMatches(tostring(dom), "images\\[\\d+\\]\\.src\\s*=\\s*'(.+?)'") do
        pages.Add(match[1])
    end

end

function Login()

    if(not http.Cookies.Contains('fusion_user')) then

        local loginUrl = 'https://'..module.Domain..'/setuser.php'        

        http.Referer = GetRoot(loginUrl)

        http.PostData.Add('user_name', username)
        http.PostData.Add('user_pass', password)
        http.PostData.Add('remember_me', 'y')
        http.PostData.Add('login', 'Войти')

        local response = http.PostResponse(loginUrl)
        
        if(not response.Cookies.Contains('fusion_user')) then
            Fail(Error.LoginFailed)
        end

        global.SetCookies(response.Cookies)

    end

end
