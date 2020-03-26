function Register()

    module.Name = 'Toomics'

    module.Type = 'Webtoon'

    module.Domains.Add('toomics.com', 'Toomics')

end

function GetInfo()

    info.Title = tostring(dom.Title):beforelast(' - ')
    info.Author = dom.SelectValue('//span[@class="type"]'):split('|')
    info.Tags = dom.SelectValue('//span[@class="writer"]'):split('/')
    info.Language = url:match('\\/\\/.+?\\/([^\\/]+)', 1)
    info.Summary = dom.SelectValue('//h2')

end

function GetChapters()

    for node in dom.SelectElements('//section[contains(@class, "ep-body")]//a') do

        local number = node.SelectValue('div[contains(@class, "cell-num")]'):trim()
        local title = node.SelectValue('div[contains(@class, "cell-title")]'):trim()
        local url = node.SelectValue('@onclick'):regex("href='([^']+)'", 1)

        chapters.Add(url, number .. ' - ' .. title)

    end

end

function GetPages()

    if(dom.SelectValue('//meta[contains(@property, "og:url")]/@content'):contains('age_verification')) then
        
        DoAgeVerification()

        dom = Dom.New(http.Get(url))

    end

    pages.AddRange(dom.SelectValues('//img[contains(@id, "set_image")]/@data-original'))

end

function DoAgeVerification()

    http.Get('https://toomics.com/en/index/set_display/?display=A')

end

--function Login()
--
--   -- Login is currently not working (login page 404s).
--
--    if(not http.Cookies.Contains('GTOOMICSacc_log')) then
--
--        http.Referer = 'https://'..module.Domain..'/'
--
--        http.PostData.Add('user_id', username)
--        http.PostData.Add('user_pw', password)
--        http.PostData.Add('save_user_id', '1')
--        http.PostData.Add('keep_cookie', '1')
--        http.PostData.Add('returnUrl', '/')
--        http.PostData.Add('direction', 'N')
--        http.PostData.Add('login_chk', '')
--        http.PostData.Add('vip_chk', 'Y')
--        
--        http.Headers['content-type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
--        http.Headers['x-requested-with'] = 'XMLHttpRequest'
--
--        local response = http.PostResponse('https://'..module.Domain..'/en/auth/layer_login')
--
--        if(not response.Cookies.Contains('GTOOMICSacc_log')) then
--            Fail(Error.LoginFailed)
--        end
--
--        global.SetCookies(response.Cookies)
--
--    end
--
--end
