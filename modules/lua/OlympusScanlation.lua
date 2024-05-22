function Register()

    module.Name = 'Olympus Scanlation'
    module.Language = 'es'
    module.Adult = false

    module.Domains.Add('olympusscans.com')
    module.Domains.Add('olympusv2.gg')
    module.Domains.Add('olympusvisor.com')
    module.Domains.Add('visorolym.com')

end

local function GetApiUrl()
    return '//dashboard.' .. module.Domain .. '/api/series/'
end

local function GetSlug()
    return url:regex('\\/series\\/(?:comic-)?([^\\/]+)', 1)
end

function GetInfo()

    local apiEndpoint = GetApiUrl() .. GetSlug()
    local json = Json.New(http.Get(apiEndpoint))

    info.Title = json.SelectValue('data.name')
    info.Summary = json.SelectValue('data.summary')

    if(isempty(info.Title)) then
        info.Title = dom.SelectValue("//h1")
    end

end

function GetChapters()

    local seriesSlug = url:regex('\\/series\\/([^\\/]+)', 1)
    local currentPageIndex = 1
    local lastPageIndex = 1

    repeat

        local apiEndpoint = GetApiUrl() .. GetSlug() .. '/chapters?page=' .. currentPageIndex .. '&direction=asc&type=comic'
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

    if(url:contains('/capitulo/')) then
        pages.AddRange(dom.SelectValues('//img[@loading]/@src'))
    end
        
end
