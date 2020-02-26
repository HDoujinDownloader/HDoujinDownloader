function Register()

    local module = module.New()

    module.Name = 'zBulu'
    module.Language = 'English'

    module.Domains.Add('bulumanga.net', 'BuluManga')
    module.Domains.Add('heavenmanga.org', 'Heaven Manga')
    module.Domains.Add('holymanga.net', 'Holy Manga')

    RegisterModule(module)

    local module = module.New()

    module.Language = 'Vietnamese'

    module.Domains.Add('mangahay.net', 'Mangahay.net')

    RegisterModule(module)

end

function GetInfo()

    info.Title = dom.SelectValue('//*[@class="bg-tt" or self::h1]')
    info.Author = dom.SelectValues('//div[contains(@class, "meta-data")]/div[contains(@class, "author")]/a')
    info.Tags = dom.SelectValues('//div[contains(@class, "meta-data")]/div[contains(@class, "genre")]/a')
    info.Status = dom.SelectValue('//span[contains(text(), "Status")]/following-sibling::span')
    info.Summary = dom.SelectValue('//p/text()')
    info.ChapterCount = dom.SelectValue('//span[contains(text(), "Total chapters")]/following-sibling::text()')

end

function GetChapters()

    url = url:before('/page-')..'/'
    dom = dom.New(http.Get(url))

    local paginationCount = dom.SelectValue('//div[contains(@class, "pagination")]/a[contains(@class, "page-numbers")][last()]/@href'):after('page-')
    paginationCount = tonumber(paginationCount) or 1

    for i = 1, paginationCount do

        chapters.AddRange(dom.SelectElements('//h2[contains(@class, "chap")]//a'))

        if(i + 1 <= paginationCount) then
            dom = dom.New(http.Get(url..'/page-'..(i + 1)))
        end

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class, "chapter-content")]//img/@src'))    

end
