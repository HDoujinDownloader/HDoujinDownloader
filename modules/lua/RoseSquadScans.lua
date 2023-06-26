require "IsekaiScan"

local BaseGetInfo = GetInfo

function Register()

    module.Name = 'Rose Squad Scans'
    module.Language = 'English'

    module.Domains.Add('rosesquadscans.aishiteru.org')

end

function GetInfo()

    BaseGetInfo()

    if(isempty(info.Title)) then
        Fail(Error.LoginRequired)
    end

    info.Scanlator = module.Name

end

function Login()

    if(isempty(http.Cookies)) then

        http.Referer = 'https://' .. module.Domain .. '/'
        
        http.PostData.Add('log', username)
        http.PostData.Add('pwd', password)
        http.PostData.Add('rememberme', 'forever')
        http.PostData.Add('wp-submit', 'Sign in')
        http.PostData.Add('redirect_to', http.Referer)
        http.PostData.Add('testcookie', '1')

        local response = http.PostResponse('https://' .. module.Domain .. '/wp-login.php')
        local success = false

        for cookie in response.Cookies do

            success = cookie.Name:startswith('wordpress_logged_in')

            if(success) then
                break
            end

        end

        if(not success) then
            Fail(Error.LoginFailed)
        end

        global.SetCookies(response.Cookies)

    end

end
