function Register()

    module.Name = 'Zerochan'
    module.Type = 'Artist CG'
    module.Strict = false
    module.Adult = false

    module.Domains.Add('zerochan.net')

end

local function GetPostUrlsFromResultPage()
    return dom.SelectValues('//ul[contains(@id,"thumbs")]//a[contains(@class,"thumb")]/@href')
end

local function GetNextResultsUrl()
    return dom.SelectValue('//nav[contains(@class,"pagination")]//a[contains(@rel,"next")]/@href')
end

function GetInfo()

    info.Title = dom.Title:beforelast('-')
    info.PageCount = dom.SelectValue('//p[contains(text(),"images.")]'):regex('[\\d,]+'):replace(',', '')
    info.Tags = dom.SelectValues('//ul[@id="tags"]//a')

    if(List.New(info.Tags).Contains('mangaka')) then
        info.Artist = info.Title
    end

    if(isempty(info.PageCount)) then
        info.PageCount = GetPostUrlsFromResultPage().Count()
    end

end

function GetPages()

    -- Add all post URLs, and the next results URL.

    local nextResultsUrl = GetNextResultsUrl()

    pages.AddRange(GetPostUrlsFromResultPage())

    if(not isempty(nextResultsUrl)) then
        pages.Add(nextResultsUrl)
    end

end

function BeforeDownloadPage()

    if(Regex.IsMatch(url, '\\/\\d+$')) then

        -- Note that it's possible for the download URL to 404.
        -- E.g. https://www.zerochan.net/13043

        local downloadUrl = dom.SelectValue('//a[contains(@class,"preview")]/@href')
        local previewUrl = dom.SelectValue('//a[contains(@class,"preview")]//img/@src')

        page.Referer = url
        page.Url = downloadUrl
        page.BackupUrls.Add(previewUrl)

    else

        GetPages()

    end

end

function Login()

    -- A login is required to access 18+ content.

    if(isempty(http.Cookies)) then

        local loginUrl = '//' .. module.Domain .. '/login'

        http.Referer = loginUrl

        http.PostData.Add('ref', '/')
        http.PostData.Add('name', username)
        http.PostData.Add('password', password)
        http.PostData.Add('login', 'Login')

        local response = http.PostResponse(loginUrl)

        if(not response.Cookies.Contains('sessionid')) then
            Fail(Error.LoginFailed)
        end

        global.SetCookies(response.Cookies)

    end

end
