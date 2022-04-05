function Register()

    module.Name = 'Ravenmanga'
    module.Language = 'es'

    module.Domains.Add('ravenmanga.xyz')

end

function GetInfo()

    info.Title = dom.SelectValue('//span[contains(@class,"info-span")]')
    info.Summary = dom.SelectValue('//div[contains(text(),"Sinopsis")]/following-sibling::div')
    info.Tags = dom.SelectValues('//div[contains(text(),"Generos")]/following-sibling::div//span')
    info.Type = dom.SelectValue('//span[contains(text(),"Tipo:")]'):after(':')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//a[contains(@class,"cap-link")]'))

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//img[contains(@class,"img-fluid")]/@src'))

end
