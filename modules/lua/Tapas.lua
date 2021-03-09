function Register()

    module.Name = 'Tapas'
    module.Language = 'English'
    module.Type = 'Webcomic'

    module.Domains.Add('tapas.io')

    -- The following cookies are required to access mature content.
    -- It doesn't matter what the birthdates are as long as they're >= 18 years ago.

    global.SetCookie(module.Domain, 'adjustedBirthDate', '1980-01-01')
    global.SetCookie(module.Domain, 'birthDate', '1980-01-01')

end

function GetInfo()

    info.Title = dom.SelectValue('//div[contains(@class,"info-body")]//a[contains(@class,"title")]')
    info.Summary = dom.SelectValue('//div[contains(@class,"info-body")]//div[contains(@class,"description")]')
    
    if(info.Title:endsWith('(Mature)')) then
        info.Adult = true
    end

    info.Title = CleanTitle(info.Title)

end

function GetChapters()

    local seriesId = tostring(dom):regex('data-series-id="(.+?)"', 1)
    local chaptersPerRequest = 20
    local paginationIndex = 1
    local totalChapters = -1

    repeat

        local apiEndpoint = '/series/'..seriesId..'/episodes?&page='..paginationIndex..'&sort=OLDEST&max_limit='..chaptersPerRequest
        local chaptersJson = Json.New(http.Get(apiEndpoint))
        local chaptersDom = Dom.New(chaptersJson.SelectValue('data.body'))

        totalChapters = tonumber(chaptersJson.SelectValue('data.pagination.total'))

        local chapterNodes = chaptersDom.SelectElements('//li[contains(@id,"ep")]')

        if(chapterNodes.Count() <= 0) then
            break
        end

        for chapterNode in chapterNodes do

            local chapterUrl = chapterNode.SelectValue('@data-href')
            local chapterTitle = chapterNode.SelectValue('.//a[contains(@class,"title")]')

            chapters.Add(chapterUrl, chapterTitle)

        end

        paginationIndex = paginationIndex + 1

    until(chapters.Count() >= totalChapters)

end

function GetPages()

    pages.AddRange(dom.SelectValues('//img[contains(@class,"content__img")]/@data-src'))

end

function Login() 

    if(not http.Cookies.Contains('JSESSIONID')) then

        local domain = module.Domain
        local endpoint = '/account/authenticate'

        http.Referer = 'https://'..domain..'/'

        http.PostData.Add('from', http.Referer)
        http.PostData.Add('email', username)
        http.PostData.Add('password', password)
        http.PostData.Add('offsetTime', 0)
        
        local response = http.PostResponse(endpoint)

        if(not response.Cookies.Contains('JSESSIONID')) then
            Fail(Error.LoginFailed)
        end

        global.SetCookies(response.Cookies)

    end

end

function CleanTitle(title)

    return RegexReplace(tostring(title), '(?i)\\(mature\\)$', '')

end
