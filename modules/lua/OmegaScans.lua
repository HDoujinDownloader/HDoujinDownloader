function Register()

    module.Name = 'Omega Scans'
    module.Language = 'English'
    module.Adult = true

    module.Domains.Add('omegascans.org')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Summary = dom.SelectValue('//div[contains(@class,"description-container")]/p')
    info.AlternativeTitle = dom.SelectValue('//div[contains(@class,"series-alternative-names")]/h6')
    info.DateReleased = dom.SelectValue('//p[contains(text(),"Release year")]/strong')
    info.Author = dom.SelectValue('//p[contains(text(),"Author: ")]/strong')
    info.Artist = dom.SelectValue('//p[contains(text(),"Author: ")]/strong')
    info.Scanlator = module.Name
    info.Publisher = dom.SelectValue('//p[contains(text(),"This series is produced by")]/strong')

    local checkEndStatus = dom.SelectValue('//*[@id="simple-tabpanel-0"]/div/span/div/ul/a[1]/li//span[contains(text(),"[END]")]')

    if(not isempty(checkEndStatus)) then

        info.Status = 'Completed'

    end

end

function GetChapters()

    for chapterJson in GetChaptersJson() do

        local chapterInfo = Json.New(chapterJson)

        if(chapterInfo.SelectValue('price') == '0') then

            local chapterUrl = url:trim('/') .. '/' .. chapterInfo.SelectValue('chapter_slug')
            local chapterTitle = chapterInfo.SelectValue('chapter_name')
            local chapterSubtitle = chapterInfo.SelectValue('chapter_title')
            
            if(chapterSubtitle ~= 'null' and not isempty(chapterSubtitle)) then
                chapterTitle = chapterTitle .. ' - ' .. chapterSubtitle
            end

            chapters.Add(chapterUrl, chapterTitle)
            
        end

    end
    
end

function GetPages()

    local pagesJson = GetPagesJson()
    
    for pageJson in pagesJson.SelectValues('content.images[*]') do

        if(pageJson:trim():startswith('http')) then

            pages.Add(pageJson)

        else

            pages.Add(GetApiUrl() .. pageJson)

        end

    end

end

function GetApiUrl()

    return '//api.omegascans.org/'

end

function GetApiJson(endpoint)

    http.Headers['accept'] = 'application/json, text/javascript, */*; q=0.01'
    http.Headers['x-requested-with'] = 'XMLHttpRequest'

    return Json.New(http.Get(GetApiUrl() .. endpoint))

end

function GetAppJs()

    return dom.SelectValue('//script[@id="__NEXT_DATA__"]')

end

function GetChapterId()

    return GetAppJs():regex('{"id":(\\d+),', 1)

end

function GetChaptersJson()

    local json = Json.New(GetAppJs())
    local chaptersJson = json.SelectValues('props.pageProps.series.chapters[*]')

    return chaptersJson

end

function GetPagesJson()

    local chapterId = GetChapterId()
    local endpoint = chapterId

    return GetApiJson('series/chapter/' .. endpoint)

end
