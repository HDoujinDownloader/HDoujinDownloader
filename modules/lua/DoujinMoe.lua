function Register()

    module.Name = 'Doujins.com'
    module.Adult = true
    module.Language = 'English'

    module.Domains.Add('doujins.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//div[contains(@class,"folder-title")]/a[last()]')
    info.Summary = dom.SelectValue('//div[contains(@class,"folder-message")]')
    info.Artist = dom.SelectValues('//div[contains(@class,"gallery-artist")]/a')
    info.Tags = dom.SelectValues('//li[contains(@class,"tag-area")]/a')

end

function GetPages()

    pages.AddRange(dom.SelectValues('//img[@id="doujinScroll"]/@data-file'))

end

function Login()

    if(not http.Cookies.Contains('doujins_session')) then

        local referer = 'https://'..module.Domain..'/'
        local dom = Dom.New(http.Get(referer))

        http.Referer = referer
        http.Headers['accept'] = 'application/json, text/plain, */*'
        http.Headers['content-type'] = 'application/json;charset=UTF-8'
        http.Headers['x-csrf-token'] = dom.SelectValue('//meta[@name="csrf-token"]/@content')
        http.Headers['x-requested-with'] = 'XMLHttpRequest'
        http.Headers['origin'] = 'https://'..module.Domain
        http.Headers['x-xsrf-token'] = http.Cookies.GetCookie('XSRF-TOKEN')

        local payload = '{"identity":"'..username..'","password":"'..password..'","site":"'..module.Domain..'","show_subscription":false}'
        local response = http.PostResponse('https://'..module.Domain..'/login', payload)

        if(not response.Cookies.Contains('doujins_session')) then
            Fail(Error.LoginFailed)
        end

        global.SetCookies(response.Cookies)

    end

end
