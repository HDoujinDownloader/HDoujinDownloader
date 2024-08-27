function Register()

    module.Name = 'ArtUntamed'
    module.Adult = true

    module.Domains.Add('artuntamed.com')

end

local function GetImagesFromMediaPage()
    return dom.SelectValues('//div[contains(@class,"media-container")]//img/@src')
end

function GetInfo()

    info.Title = dom.SelectValue('//title'):beforelast('|')
    info.Artist = info.Title:regex('Media added by\\s([^|]+)', 1)
    info.PageCount = '?'

end

function GetPages()

    -- URLs on this site can take many forms:
    -- /index.php?tags/<tag>/
    -- /index.php?media/users/<user-id>/
    -- /index.php?media/<media-id>/
    -- /index.php?media/

    for page in Paginator.New(http, dom, '//div[contains(@class,"pageNav")]//a[contains(@class,"next")]/@href') do

        -- Add all media URLs if this is a thumbnail gallery.

        pages.AddRange(page.SelectValues('//a[contains(@class,"js-lbImage")]/@href'))

        -- Add all media URLs if this is a tag gallery.

        pages.AddRange(page.SelectValues('//*[contains(@class,"contentRow-title")]//a/@href'))

    end

    if(isempty(pages)) then
        pages.Add(url)
    end

    -- Galleries are organized reverse-chronologically.

    pages.Reverse()

end

function BeforeDownloadPage()

    if(page.Url:endswith('/full')) then
        return
    end

    page.Referer = page.Url
    page.Url = GetImagesFromMediaPage()[0]

end

function Login()

    if(isempty(http.Cookies)) then

        local endpoint = '/index.php?login/login'
        local dom = Dom.New(http.Get(endpoint))
        local xsrfToken = dom.SelectValue('//input[contains(@name,"_xfToken")]/@value')

        http.PostData.Add('_xfToken', xsrfToken)
        http.PostData.Add('login', username)
        http.PostData.Add('password', password)
        http.PostData.Add('remember', '1')
        http.PostData.Add('_xfRedirect', '')

        local response = http.PostResponse(endpoint)

        if(not response.Cookies.Contains('xf_user')) then
            Fail(Error.LoginFailed)
        end

        global.SetCookies(response.Cookies)

    end

end
