function Register()

    module.Name = 'TuMangaOnline'
    module.Language = 'Spanish'
    module.Type = 'Manga'

    module.Domains.Add('lectortmo.com', 'TuMangaOnline')

end

function GetInfo()

    info.Title = dom.SelectValue('//div[contains(@class,"element-header-content-text")]/h1/text()')
    info.DateReleased = dom.SelectValue('//h1/small'):between('(', ')')
    info.OriginalTitle = dom.SelectValue('//h1/following-sibling::h2')
    info.Type = dom.SelectValue('//h1')
    info.Summary = dom.SelectValue('//p[contains(@class,"description")]')
    info.Tags = dom.SelectValues('//h5[contains(text(),"Géneros")]/following-sibling::h6')
    info.Status = dom.SelectValue('//h5[contains(text(),"Estado")]/following-sibling::span')
    info.AlternativeTitle = dom.SelectValues('//h5[contains(text(),"alternativos")]/following-sibling::span')

    -- Added from the reader?

    if(isempty(info.Title)) then
        info.Title = dom.SelectValue('//h2')
    end

end

function GetChapters()

    local chapterNodes = dom.SelectElements('//div[@id="chapters"]//li[contains(@class,"upload-link")]')
    
    chapterNodes.Reverse()
    
    for chapterNode in chapterNodes do

        local chapterTitle = chapterNode.SelectValue('.//h4')
        local uploadNodes = chapterNode.SelectElements('.//li')

        for i=0,uploadNodes.Count() - 1 do

            local chapterInfo = ChapterInfo.New()

            chapterInfo.Title = chapterTitle
            chapterInfo.ScanlationGroup = uploadNodes[i].SelectValue('.//span')
            chapterInfo.Url = uploadNodes[i].SelectValue('.//a[span[contains(@class,"fa-play")]]/@href')
            chapterInfo.Language = uploadNodes[i].SelectValue('//i[contains(@class,"flag-icon")]/@class'):regex('flag-icon-(.+?)$', 1)

            chapters.Add(chapterInfo)

        end

    end

end

function GetPages()

    -- Follow the redirect and get the final viewer URL.

    url = dom.SelectValue('//meta[@property="og:url"]/@content')

    -- Switch to "cascade" mode so we can easily access all of the images.

    url = RegexReplace(url, '\\/(?:cascade|paginated)$', '/cascade')

    dom = dom.New(http.Get(url))

    pages.AddRange(dom.SelectValues('//img/@data-src'))

end
