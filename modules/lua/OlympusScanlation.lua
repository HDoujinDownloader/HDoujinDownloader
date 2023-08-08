function Register()

    module.Name = 'Olympus Scanlation'
    module.Language = 'es'
    module.Adult = false

    module.Domains.Add('olympusscans.com')
    module.Domains.Add('olympusv2.gg')

end

function GetInfo()

    info.Title = dom.SelectValue("//h1")

end

function GetChapters()

    local slug = url:regex('\\/series\\/(?:comic-)?([^\\/]+)', 1)
    local seriesSlug = url:regex('\\/series\\/([^\\/]+)', 1)
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

    if(url:contains('/capitulo/')) then
        pages.AddRange(dom.SelectValues('//img[@loading]/@src'))
    end
        
end
