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

local function GetComicId()

    return GetParameter(dom.SelectValue('//a[contains(@class,"subscribe-cnt")]/@href'), "series_id")

end

local function CleanTitle(title)

    -- Read The Beginning After the End | Tapas Web Comics

    return RegexReplace(tostring(title), '(?i)^(?:Read\\s*)|(?:\\(mature\\)|\\s*\\|\\s*Tapas Web Comics)$', '')

end

function GetInfo()

    info.Title = dom.SelectValue('//div[contains(@class,"title-wrapper")]')
    info.Author = dom.SelectValues('//ul[contains(@class,"detail-row__body--creator")]//a[contains(@class,"name")]')
    info.Summary = dom.SelectValue('//span[contains(@class,"description__body")]')
    info.Tags = dom.SelectValues('//div[contains(@class,"info-detail")]//a[contains(@class,"genre-btn")]')
    
    if(info.Title:endswith('(Mature)')) then
        info.Adult = true
    end

    info.Title = CleanTitle(info.Title)

end

function GetChapters()

    local seriesId = GetComicId()
    local chaptersPerRequest = 20
    local paginationIndex = 1
    local totalChapters = -1
    repeat

        local apiEndpoint = '/series/'..seriesId..'/episodes?&page='..paginationIndex..'&sort=OLDEST&max_limit='..chaptersPerRequest
        local chaptersJson = Json.New(http.Get(apiEndpoint))
        
	    totalChapters = tonumber(chaptersJson.SelectValue('data.pagination.total'))
        local episodes = Json.New(chaptersJson.SelectValue('data.episodes'))    
        if(episodes.Count() <= 0) then
            break
        end
        for chapterJson in episodes do
            if(chapterJson.SelectValue('scene') ~= '0') then -- Remove unreleased chapters
                if(chapterJson.SelectValue('free') == "true" or chapterJson.SelectValue('unlocked') == "true") then -- only load accessable chapters
                    local episodeNum = chapterJson.SelectValue('pending_scene')
                    local chapterUrl = '/episode/' .. chapterJson.SelectValue('id')
                    local chapterTitle = episodeNum .. ' - ' .. chapterJson.SelectValue('title')
                    chapters.Add(chapterUrl, chapterTitle)
                end
            end
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
