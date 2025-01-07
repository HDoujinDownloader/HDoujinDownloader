function Register()

    module.Name = 'Crystal Scan'
    module.Language = 'pt-br'

    module.Domains.Add('crystalcomics.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Status = dom.SelectValue('//div[contains(@class,"status")]')
    info.Summary = dom.SelectValue('//div[contains(@class,"excerpt")]')

end

function GetChapters()

    for chapterNode in dom.SelectElements('//div[contains(@class,"chapter-list")]//li/a') do

        local chapterUrl = chapterNode.SelectValue('./@href')
        local chapterTitle = chapterNode.SelectValue('.//div[contains(@class,"title")]')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()
    pages.AddRange(dom.SelectValues('//div[contains(@class,"chapter-images")]//img/@src'))
end
