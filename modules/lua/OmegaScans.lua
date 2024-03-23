function Register()

    module.Name = 'Omega Scans'
    module.Language = 'English'
    module.Adult = true

    module.Domains.Add('omegascans.org')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Summary = dom.SelectValue('//*[@id="content"]/div[1]/div/div[1]/div/div[1]/div[3]/div/p')
    info.AlternativeTitle = dom.SelectValue('//h1//following-sibling::span')
    info.DateReleased = dom.SelectValue('//span[contains(text(),"Release year")]//following-sibling::span')
    info.Author = dom.SelectValue('//span[contains(text(),"Author")]//following-sibling::span')
    info.Artist = dom.SelectValue('//span[contains(text(),"Author")]//following-sibling::span')
    info.Scanlator = module.Name
    info.Tags = dom.SelectValues('//*[@id="content"]/div[1]/div/div[1]/div/div[1]//span[contains(@class,"font-bold") and contains(@class,"rounded")]')

    if (info.Tags:contains('Completed')) then
        info.Status = 'completed'
    else
        info.Status = 'ongoing'
    end

end

function GetChapters()

    local comicId = GetAppJs():regex('series_id\\\\":(\\d+),', 1)

    if(isempty(comicId)) then
        return
    end

    local baseUrl = StripParameters(url):trim('/') .. '/'
    local apiUrl = 'chapter/query/?series_id=' .. comicId .. '&perPage=30'
    local pageIndex = 1
    local pageCount = 0

    repeat

        local endpoint = SetParameter(apiUrl, 'page', pageIndex)
        local json = GetApiJson(endpoint)
 
        for chapterJson in json.SelectTokens('data[*]') do

            if(chapterJson.SelectValue('price') == '0') then

                local chapterUrl = baseUrl .. chapterJson.SelectValue('chapter_slug')
                local chapterTitle = ''

                if(chapterJson.SelectValue('chapter_title') == '') then
                    chapterTitle = chapterJson.SelectValue('chapter_name')
                else
                    chapterTitle = chapterJson.SelectValue('chapter_name') .. ' - ' .. chapterJson.SelectValue('chapter_title')
                end

                chapters.Add(chapterUrl, chapterTitle)

            end

        end

        pageIndex = pageIndex + 1
        pageCount = tonumber(json.SelectValue('meta.last_page'))

    until(pageIndex > pageCount)

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//img[contains(@data-src, "/uploads/series/")]/@data-src|//img[contains(@src, "/uploads/series/")]/@src'))

end

function GetApiUrl()

    return '//api.omegascans.org/'

end

function GetApiJson(endpoint)

    http.Headers['accept'] = 'application/json, text/plain, */*'

    return Json.New(http.Get(GetApiUrl() .. endpoint))

end

function GetAppJs()

    return dom.SelectValue('//script[contains(text(),"series_id")]')

end
