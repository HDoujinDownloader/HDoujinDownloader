-- EarlyManga is very similar to MangaDex, minus the API.

function Register()

    module.Name = 'EarlyManga'
    module.Language  = 'English'

    module.Domains.Add('earlymanga.org', 'EarlyManga')

end

function GetInfo()

    info.Title = dom.SelectValue('//span[contains(@class,"mx-1")]')
    info.Type = dom.SelectValue('//span[contains(@class,"flag")]/@title')
    info.AlternativeTitle = dom.SelectValues('//li[contains(@class,"alt-name")]/span')
    info.Author = dom.SelectValues('//div[contains(text(),"Author")]/following-sibling::div/a')
    info.Artist = dom.SelectValues('//div[contains(text(),"Artist")]/following-sibling::div/a')
    info.Tags = dom.SelectValues('//div[contains(text(),"Demographic") or contains(text(),"Format") or contains(text(),"Genre") or contains(text(),"Theme")]/following-sibling::div/a')
    info.Status = dom.SelectValue('//div[contains(text(),"Pub. status")]/following-sibling::div')
    info.Summary = dom.SelectValues('//div[contains(text(),"Description")]/following-sibling::div[last()]/text()').Join('\n\n')
    
end

function GetChapters()

    for page in Paginator.New(http, dom, '//li[@aria-current="page"]/following-sibling::li/a/@href') do
    
        local chapterNodes = page.SelectElements('//div[@id="chapters"]//div[contains(@class,"chapter-row") and .//@href]')

        for i = 0, chapterNodes.Count() - 1 do

            local chapterNode = chapterNodes[i]
            local chapter = ChapterInfo.New()

            chapter.Url = chapterNode.SelectValue('.//a[not(@style)]/@href')
            chapter.Title = chapterNode.SelectValue('.//a[not(@style)]')
            chapter.Language = chapterNode.SelectValue('.//span[contains(@class,"flag")]/@title')

            chapters.Add(chapter)

        end

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"chapter-images")]/img/@src'))

end
