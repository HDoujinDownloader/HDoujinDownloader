function Register()

    module.Name = 'Manganelo'
    module.Language = 'English'

    module.Domains.Add('manganelo.com', 'Manganelo')

end

function GetInfo()

    info.Title = tostring(dom.GetElementsByTagName('h1')[0]):title()
    info.AlternativeTitle = dom.SelectValue('//td[contains(text(), "Alternative")]/following-sibling::td/text()')
    info.Author = dom.SelectValues('//td[contains(text(), "Author")]/following-sibling::td/a/text()')
    info.Status = dom.SelectValue('//td[contains(text(), "Status")]/following-sibling::td/text()')
    info.Tags = dom.SelectValues('//td[contains(text(), "Genres")]/following-sibling::td/a/text()')
    info.Summary = tostring(dom.SelectElement('//div[contains(@class, "info-description")]')):after('Description :')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//div[contains(@class, "chapter-list")]//a'))

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class, "chapter-reader")]/img/@src'))

end
