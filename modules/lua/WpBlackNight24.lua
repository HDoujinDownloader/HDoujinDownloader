function Register()

    module.Name = 'Black Night 24'
    module.Language = 'pt'
    module.Adult = true

    module.Domains.Add('toonx.net', 'ToonX')

end

function GetInfo()

        info.Title = dom.SelectValue('//h1')
        info.Tags = dom.SelectValues('//div[contains(text(),"Etiquetas")]/following-sibling::div//a')

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"wp-content")]//img[not(@role)]/@src'))

end
