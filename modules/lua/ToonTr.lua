function Register()

    module.Name = 'ToonTR Comics'
    module.Language = 'Turkish'
    module.Type = 'Webtoon'

    module.Domains.Add('mangasloth.com', 'ToonTR Comics')

end

function GetInfo()

    info.Title = dom.SelectValue('//h3')
    info.Summary = dom.SelectValue('//p[contains(@class, "description")]')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//table//a'))

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//img[contains(@class, "chapter-image")]/@src'))

end
