function Register()

    module.Name = 'MangaBuddy'
    module.Language = 'en'

    module.Domains.Add('mangabuddy.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.AlternativeTitle = dom.SelectValue('//h2')
    info.Author = dom.SelectValues('//strong[contains(.,"Authors")]/following-sibling::a')
    info.Status = dom.SelectValues('//strong[contains(.,"Status")]/following-sibling::a')
    info.Tags = dom.SelectValues('//strong[contains(.,"Genres")]/following-sibling::a')
    info.Summary = dom.SelectValue('//p[contains(@class,"content")]')

end

function GetChapters()

    for chapterNode in dom.SelectElements('//ul[@id="chapter-list"]//a') do

        local chapterUrl = chapterNode.SelectValue('@href')
        local chapterTitle = chapterNode.SelectValue('.//*[contains(@class,"chapter-title")]')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[@id="chapter-images"]//img/@data-src'))

end
