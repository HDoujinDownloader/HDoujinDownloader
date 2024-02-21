function Register()

    module.Name = 'MangaTown'
    module.Language = 'English'

    module.Domains.Add('mangatown.com', 'MangaTown')
    module.Domains.Add('www.mangatown.com', 'MangaTown')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.AlternativeTitle = dom.SelectValue('//b[contains(text(),"Alternative Name")]/following-sibling::text()'):split(';')
    info.Tags = dom.SelectValues('//b[contains(text(),"Genre")]/following-sibling::a')
    info.Author = dom.SelectValues('//b[contains(text(),"Author")]/following-sibling::a')  
    info.Artist = dom.SelectValues('//b[contains(text(),"Artist")]/following-sibling::a')
    info.Status = dom.SelectValues('//b[contains(text(),"Status")]/following-sibling::text()[1]')
    info.Type = dom.SelectValues('//b[contains(text(),"Type")]/following-sibling::a')
    info.Summary = dom.SelectValue('//b[contains(text(),"Summary")]/following-sibling::span[@id="show"]/text()[1]')

    local pageCount = ParsePageCount()

    if(not isempty(pageCount)) then
        info.PageCount = pageCount
    end

end

function GetChapters()

    for node in dom.SelectElements('//ul[contains(@class,"chapter_list")]/li') do
        
        local chapterUrl = node.SelectValue('a/@href')
        local chapterTitle = node.SelectValue('a')
        local chapterSubtitle = node.SelectValue('span[not(@class)]')

        -- Some chapters have a subtitle, but not all of them.

        if(not isempty(chapterSubtitle)) then
            chapterTitle = chapterTitle .. ' - ' .. chapterSubtitle
        end

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    local baseUrl = RegexReplace(url, '\\/(?:\\d+\\.html)?$', '') .. '/'
    local pageCount = tonumber(ParsePageCount())

    if(pageCount ~= nil) then
        
        for i = 1, pageCount do

            local imageUrl = dom.SelectValue('//div[contains(@class,"read_img")]/a/img/@src')
            local nextPageUrl = dom.SelectValue('//a[contains(@class,"next_page")]/@href')
    
            -- Annoying workaround for bug involving relative URIs in v1.19.9.32-r.8.
    
            if(not nextPageUrl:startsWith('/')) then
                nextPageUrl = baseUrl .. nextPageUrl
            end
            
            pages.Add(imageUrl)
    
            if(not isempty(nextPageUrl)) then
                dom = Dom.New(http.Get(nextPageUrl))
            end
    
        end

    else

        -- This chapter isn't paginated, so we can just get all of the images directly.

        pages.AddRange(dom.SelectValues('//div[contains(@id,"viewer")]//img/@src'))

    end

end

function ParsePageCount()

    return dom.SelectValue('//div[contains(@class,"page_select")]/select/option[last()-1]/text()')

end
