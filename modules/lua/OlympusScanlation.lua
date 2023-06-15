function Register()

    module.Name = 'Olympus Scanlation'
    module.Language = 'es'
    module.Adult = false

    module.Domains.Add('olympusscans.com')

end

function GetInfo()

    local titleJson = GetTitleJson()

    info.Title = titleJson.SelectValue('data..data.name')
    info.Summary = titleJson.SelectValue('data..data.summary')
    info.Tags = titleJson.SelectValues('data..data.genres[*].name')
    info.Scanlator = module.Name

end

function GetChapters()

    local titleJson = GetTitleJson()

    local slug = titleJson.SelectValue('data..data.slug')
    local seriesSlug = url:regex('\\/series\\/([^\\/#?]+)$', 1)
    local currentPageIndex = 1
    local lastPageIndex = 1

    repeat

        local apiEndpoint = '//dashboard.' .. module.Domain .. '/api/series/' .. slug .. '/chapters?page=' .. currentPageIndex .. '&direction=asc&type=comic'
        local chaptersJson = Json.New(http.Get(apiEndpoint))
        local lastPageStr = chaptersJson.SelectValue('meta.last_page')
        local chapterNodes = chaptersJson.SelectTokens('data[*]')

        if(isempty(chapterNodes)) then
            break
        end

        for chapterNode in chapterNodes do

            local chapterId = chapterNode.SelectValue('id')
            local chapterTitle = 'Capítulo ' .. chapterNode.SelectValue('name')
            local chapterUrl  = '/capitulo/' .. chapterId .. '/' .. seriesSlug

            chapters.Add(chapterUrl, chapterTitle)

        end

        if(isnumber(lastPageStr)) then
            lastPageIndex = tonumber(lastPageStr)
        end

        currentPageIndex = currentPageIndex + 1

    until(currentPageIndex > lastPageIndex)

end

function GetPages()

    pages.AddRange(dom.SelectValues('//img[@loading]/@src'))    

end

function GetTitleJson()

    local metadataScript = dom.SelectValue('//script[contains(text(),"window.__NUXT__")]')

    local js = JavaScript.New()

    js.Execute('window = {}')

    return js.Execute(metadataScript).ToJson()

end
