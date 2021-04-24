function Register()

    module.Name = 'HentaiMimi'
    module.Adult = true

    module.Domains.Add('hentaimimi.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h3[contains(@class,"lead")]')
    info.Artist = dom.SelectValues('//p[contains(text(),"Artist")]/following-sibling::p/a')
    info.Language = dom.SelectValues('//p[contains(text(),"Language")]/following-sibling::p')
    info.Magazine = dom.SelectValues('//p[contains(text(),"Magazine")]/following-sibling::p')
    info.Publisher = dom.SelectValues('//p[contains(text(),"Publisher")]/following-sibling::p')
    info.Summary = dom.SelectValues('//p[contains(text(),"Description")]/following-sibling::p')
    info.Tags = dom.SelectValues('//p[contains(text(),"Tags")]/following-sibling::p/a')

end

function GetPages()

    local doc = tostring(dom)
    local baseUrl = doc:regex('urlTo\\s*=\\s*"([^"]+)"', 1)
    local previewImages = doc:regex('previewImages\\s*=\\s*(\\[[^]]+\\])', 1)
    local previewImagesJson = Json.New(previewImages)

    for imageUrl in previewImagesJson.SelectValues('[*]') do
        pages.AddRange(baseUrl..'/'..imageUrl)
    end

end
