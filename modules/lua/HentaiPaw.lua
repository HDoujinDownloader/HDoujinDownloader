function Register()

    module.Name = 'HentaiPaw'
    module.Language = 'en'
    module.Adult = true

    module.Domains.Add('hentaipaw.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Artist = dom.SelectValues('//span[contains(text(),"Artists:")]/following-sibling::a')
    info.Circle = dom.SelectValues('//span[contains(text(),"Groups:")]/following-sibling::a')
    info.Parody = dom.SelectValues('//span[contains(text(),"Parodies:")]/following-sibling::a')
    info.Characters = dom.SelectValues('//span[contains(text(),"Characters:")]/following-sibling::a')
    info.Tags = dom.SelectValues('//span[contains(text(),"Tags:")]/following-sibling::a')
    info.Language = dom.SelectValues('//span[contains(text(),"Language:")]/following-sibling::a')
    info.Type = dom.SelectValues('//span[contains(text(),"Category:")]/following-sibling::a')

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"detail-gallery")]//img/@data-src'))

end
