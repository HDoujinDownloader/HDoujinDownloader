function Register()

    module.Name = 'Toomics'
    module.Type = 'Webtoon'

    module.Domains.Add('global.toomics.com')
    module.Domains.Add('toomics.com')

end

local function DoAgeVerification()

    http.Get('//'..module.Domain..'/en/index/set_display/?display=A')

end

function GetInfo()

    info.Title = dom.SelectValue('//div[contains(@class,"title_content")]/h1')
    info.Author = dom.SelectValue('//span[@class="writer"]/text()[1]')
    info.Artist = dom.SelectValue('//span[@class="writer"]/text()[2]')
    info.Tags = dom.SelectValue('//span[@class="type"]'):split('/')
    info.Language = url:regex('\\/(en|ko|sc|tc)\\/', 1)
    info.Summary = dom.SelectValue('//h2')
    info.Status = dom.SelectValue('//span[@class="date"]')

end

function GetChapters()

    for node in dom.SelectElements('//section[contains(@class, "ep-body")]//a') do

        local number = node.SelectValue('div[contains(@class, "cell-num")]'):trim()
        local title = node.SelectValue('div[contains(@class, "cell-title")]'):trim()
        local url = node.SelectValue('@onclick'):regex("(?:'login',\\s|href=)'(.+?)'", 1)

        chapters.Add(url, number .. ' - ' .. title)

    end

end

function GetPages()

    if(dom.SelectValue('//meta[contains(@property, "og:url")]/@content'):contains('age_verification')) then
        
        DoAgeVerification()

        dom = Dom.New(http.Get(url))

    end

    pages.AddRange(dom.SelectValues('//img[contains(@id, "set_image")]/@data-src'))

end

--[[ function Login()

  -- Login is currently not working (login page 404s).

    if(not http.Cookies.Contains('GTOOMICSremember_id')) then

        local originUrl = 'https://' .. module.Domain
        local refererUrl = originUrl .. '/en'
        local loginEndpoint = refererUrl .. '/auth/layer_login'
        
        http.Get(refererUrl)

        http.Referer = refererUrl

        http.PostData.Add('user_id', username)
        http.PostData.Add('user_pw', password)
        http.PostData.Add('save_user_id', '1')
        http.PostData.Add('keep_cookie', '1')
        http.PostData.Add('returnUrl', '/')
        http.PostData.Add('direction', 'N')
        http.PostData.Add('login_chk', '')
        http.PostData.Add('vip_chk', 'Y')

        http.Headers['accept'] = 'application/json, text/javascript, */*; q=0.01'
        http.Headers['content-type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
        http.Headers['origin'] = originUrl
        http.Headers['x-requested-with'] = 'XMLHttpRequest'

        -- Add the "click position" cookie, which is set when the mouse is clicked.

        http.Cookies.Add('.toomics.com', 'cp', '0%7C0')

        local response = http.PostResponse(loginEndpoint)

        if(not response.Cookies.Contains('GTOOMICSremember_id')) then
            Fail(Error.LoginFailed)
        end

        global.SetCookies(response.Cookies)

    end

end ]]
