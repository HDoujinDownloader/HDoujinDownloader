function Register() 

    module = Module.New()

    module.Name = 'KomiRaw'
    module.Language = 'Japanese'
    module.Type = 'Manga'

    module.Domains.Add('komiraw.com', 'Komiraw.com')
    module.Domains.Add('manga11.com', 'Manga11')
    
    RegisterModule(module)

    module = Module.New()

    module.Language = 'English'
    module.Type = 'Manhua'

    module.Domains.Add('manhuared.com', 'Manhuared.com')

    RegisterModule(module)

end

function GetInfo()

    info.Title = dom.SelectValue('//h3[contains(@class,"title")]')
    info.OriginalTitle = info.Title:before('|'):trim()
    info.Summary = dom.SelectValue('//div[contains(@class,"desc-text")]')
    info.Author = dom.SelectValues('//h3[contains(text(),"Author")]/following-sibling::a')
    info.Tags = dom.SelectValues('//h3[contains(text(),"Genre")]/following-sibling::a')
    info.AlternativeTitle = dom.SelectValue('//h3[contains(text(),"Alternative")]')

    if(isempty(info.Title)) then

        -- Added from chapter page URL.

        info.Title = dom.SelectValue('//a[@class="chapter-title"]')

    end

end

function GetChapters()

    for page in Paginator.New(http, dom, '//a[@rel="next"]/@href') do

        local chapterNodes = page.SelectElements('//ul[contains(@class,"list-chapter")]//a')

        for i = 0, chapterNodes.Count() - 1 do

            local chapterTitle = chapterNodes[i].SelectValue('@title')
            local chapterUrl = chapterNodes[i].SelectValue('@href')

            chapters.Add(chapterUrl, chapterTitle)

        end

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//img[contains(@class,"chapter-img")]/@src'))

    -- We might need to get the pages a different way for some domains (manhuared.com).

    if(pages.Count() <= 0) then
        pages.AddRange(dom.SelectValues('//img/@data-src'))
    end

end
