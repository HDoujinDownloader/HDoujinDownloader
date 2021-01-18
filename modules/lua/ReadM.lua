function Register()

    module.Name = 'readm.org'
    module.Language = 'English'

    module.Domains.Add('readm.org')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.AlternativeTitle = dom.SelectValue('//div[contains(@class,"sub-title")]')
    info.Status = dom.SelectValue('//span[contains(@class,"series-status")]')
    info.Summary = dom.SelectValue('//p/span')
    info.Tags = dom.SelectValues('//span[contains(.,"Genres")]/following-sibling::a')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//div[contains(@class,"episodes-list")]//a'))

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"ch-images")]//img/@src'))

end
