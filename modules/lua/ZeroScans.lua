function Register()

    module.Name = 'Zero Scans'
    module.Language = 'en'

    module.Domains.Add('zeroscans.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//div[contains(@class,"v-card__title")]')
    info.Tags = dom.SelectValues('//div[contains(@class,"v-slide-group__content")]//a[contains(@href,"genres")]')
    info.Summary = dom.SelectValue('//div[contains(@class,"v-card__text")]')
    info.Status = dom.SelectValue('//span[contains(@class,"v-chip__content")]')
    info.Scanlator = module.Name

end

function GetChapters()

    local comicId = GetAppJs():regex('{id:(\\d+),.+\\);', 1)

    if(isempty(comicId)) then
        return
    end

    local baseUrl = StripParameters(url):trim('/') .. '/'
    local apiUrl = 'comic/' .. comicId .. '/chapters?sort=desc'
    local pageIndex = 1
    local pageCount = 0

    repeat

        local endpoint = SetParameter(apiUrl, 'page', pageIndex)
        local json = GetApiJson(endpoint)

        for chapterJson in json.SelectTokens('data.data[*]') do

            local chapterUrl = baseUrl .. chapterJson.SelectValue('id')
            local chapterTitle = 'Chapter ' .. chapterJson.SelectValue('name')

            chapters.Add(chapterUrl, chapterTitle)

        end

        pageIndex = pageIndex + 1
        pageCount = tonumber(json.SelectValue('data.last_page'))

     until(pageIndex > pageCount)

     chapters.Reverse()

end

function GetPages()

    local pagesJs = GetAppJs():regex('high_quality:\\s*(\\[.+?\\])', 1)
    local pagesJson = Json.New(pagesJs)

    pages.AddRange(pagesJson.SelectValues('[*]'))

end

local function GetApiUrl()

    return '//zeroscans.com/swordflake/'

end

function GetApiJson(endpoint)

    local xsrfToken = http.Cookies.GetCookie('XSRF-TOKEN')

    http.Headers['accept'] = 'application/json, text/plain, */*'

    if(not isempty(xsrfToken)) then
        http.Headers['x-xsrf-token'] = xsrfToken
    end

    return Json.New(http.Get(GetApiUrl() .. endpoint))

end

function GetAppJs()

    return dom.SelectValue('//script[contains(text(),"window.__ZEROSCANS__")]')

end
