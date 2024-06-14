function Register()

    module.Name = 'Asap Theme'
    module.Language = 'pt'
    module.Adult = true

    module.Domains.Add('comics18.net', 'COMICSPORNO XXX')
    module.Domains.Add('comics18.org', 'Comics18')

end

function GetInfo()

        info.Title = dom.SelectValue('//h1')
        info.Tags = dom.SelectValues('//div[contains(@class,"content-tags")]//a')

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"the-content")]//img/@src'))

end
