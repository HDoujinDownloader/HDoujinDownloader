function Register()

    module.Name = 'Rawdevart'
    
    module.Domains.Add('rawdevart.com', 'Rawdevart')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Tags = dom.SelectValues('//div[contains(@class, "genres")]/a')
    info.AlternativeTitle = dom.SelectValues('//tr[contains(., "Alt. titles")]/following-sibling::tr')
    info.Type = dom.SelectValues('//th[contains(text(), "Type")]/following-sibling::td')
    info.Author = dom.SelectValues('//th[contains(text(), "Author")]/following-sibling::td')
    info.Artist = dom.SelectValues('//th[contains(text(), "Artist")]/following-sibling::td')
    info.Status = dom.SelectValues('//th[contains(text(), "Status")]/following-sibling::td')
    info.Publisher = dom.SelectValues('//th[contains(text(), "Publisher")]/following-sibling::td')
    info.DateReleased = dom.SelectValues('//th[contains(text(), "Release Year")]/following-sibling::td')
    info.Summary = dom.SelectValue('//div[contains(@class, "description")]//p[2]')
    info.Tags = dom.SelectValues('//h6[contains(text(), "Tags")]/following-sibling::a')
    info.ChapterCount = dom.SelectValue('//div[contains(@class, "manga-top-info")]//i[contains(@class, "fa-book")]/following-sibling::span'):regex('^\\d+')

    -- Make sure we're on the first page of chapters.

    info.Url = info.Url:before('?page=')

end

function GetChapters()

    for page in Paginator.New(http, dom, '//li[contains(@class, "active")]/following-sibling::li/a/@href') do

        local chapterNodes = page.SelectElements('//div[contains(@class, "list-group")]//a')

        for i = 0, chapterNodes.Count() - 1 do

            local chapterUrl = chapterNodes[i].SelectValue('@href')
            local chapterTitle = chapterNodes[i].SelectValue('span')

            chapters.Add(chapterUrl, chapterTitle)

        end

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[@id="img-container"]//img/@data-src'))
 
end
