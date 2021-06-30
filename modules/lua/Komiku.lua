function Register()

    module.Name = 'Komiku'
    module.Language = 'Indonesian'

    module.Domains.Add('komiku.id')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.AlternativeTitle = dom.SelectValue('//p[contains(@class,"j2")]')
    info.Summary = dom.SelectValue('//p[contains(@class,"desc")]')
    info.Type = dom.SelectValue('//td[contains(text(),"Jenis Komik")]/following-sibling::td')
    info.Status = dom.SelectValue('//td[contains(text(),"Status")]/following-sibling::td')
    info.ReadingDirection = dom.SelectValue('//td[contains(text(),"Cara Baca")]/following-sibling::td')
    info.Tags = dom.SelectValues('//ul[contains(@class,"genre")]/li')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//section[@id="Chapter"]//a'))

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//img[@data-src]/@data-src'))

end
