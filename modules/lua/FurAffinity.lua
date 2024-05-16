function Register()

    module.Name = 'FurAffinity'

    module.Domains.Add('furaffinity.net', 'FurAffinity')
    module.Domains.Add('www.furaffinity.net', 'FurAffinity')

end

local function DetectRegisteredOnly()

    return dom.SelectValue('//p[contains(@class,"link-override")]')
        :contains('registered users only')

end

function GetInfo()

    -- Some users' galleries are only accessible when logged in.
    -- An account is also required in order to access "mature" content.

    if(DetectRegisteredOnly()) then
        Fail(Error.LoginRequired)
    end

    if(url:contains('/view/')) then

        -- Added a single image.

        info.Title = dom.SelectValue('//div[contains(@class,"submission-title")]')
        info.Artist = dom.SelectValue('//div[contains(@class,"section-header")]//strong')
        info.Summary = dom.SelectValue('//div[contains(@class,"submission-description")]')
        info.Tags = dom.SelectValue('//meta[@name="keywords"]/@content'):split(' ')

    else

        -- Added user gallery.

        info.Title = tostring(dom.Title):before('--'):trim()
        info.Artist = dom.SelectValue('//div[contains(@class,"username")]/h2')
        info.Summary = dom.SelectValue('//div[contains(@class,"username")]/span')
        info.PageCount = '?'

    end

end

function GetPages()

    if(url:contains('/view/')) then

        -- If a single image was added, we've already got the URL of the work.

        pages.Add(url)

    else

        -- Add all images in the user's gallery.

        -- Make sure we're on the first page of the user's gallery page.

        url = url:replace('/user/', '/gallery/')
        url = RegexReplace(url, '\\/\\d+\\/\\?.*?$', '')..'/'

        dom = Dom.New(http.Get(url))

        for page in Paginator.New(http, dom, '//form[button[text()="Next"]]/@action') do
            pages.AddRange(page.SelectValues('//figure[contains(@class,"t-image")]//u/a/@href'))
        end

        -- Gallery is ordered from newest to oldest, so we need to reverse the list.

        pages.Reverse()

    end

end

function BeforeDownloadPage()

    -- We have the URL of the work, so we need to get the full image URL.

    local dom = Dom.New(http.Get(page.Url))

    -- Attempt to get the image URL from the "Download" button.
   
    local fullImageUrl = dom.SelectValue('//a[text()="Download"]/@href')

    -- If this fails, get the image shown on the page.

    if(isempty(fullImageUrl)) then
        fullImageUrl = dom.SelectValue('//img/@data-fullview-src')
    end

    page.Url = fullImageUrl

end

function Login()

    if(not http.Cookies.Contains('a')) then

        local domain = module.Domain

        http.Referer = 'https://www.'..domain..'/login/'
        
        local dom = Dom.New(http.Get('https://www.'..domain..'/login/'))
        
        local captchaUrl = GetRooted(dom.SelectValue('//img[@id="captcha_img"]/@src'), url)
        local captchaSolution = Captcha.Solve(http, captchaUrl)

        http.PostData.Add('action', 'login')
        http.PostData.Add('name', username)
        http.PostData.Add('pass', password)
        http.PostData.Add('g-recaptcha-response', '')
        http.PostData.Add('use_old_captcha', '1')
        http.PostData.Add('captcha', captchaSolution)
        http.PostData.Add('login', 'Login to Fur Affinity')

        local response = http.PostResponse('https://www.'..domain..'/login/?ref='..http.Referer)

        if(not response.Cookies.Contains('a')) then
            Fail(Error.LoginFailed)
        end

        global.SetCookies(response.Cookies)

    end

end
