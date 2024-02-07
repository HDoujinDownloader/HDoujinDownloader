function Register()

    module.Name = 'Hentai2.net'
    module.Adult = true

    module.Domains.Add('hentai2.net')
    module.Domains.Add('www2.hentai2.net')

end

function GetInfo()

    info.Title = dom.SelectValue('//h3[contains(@class,"title")]')
    info.Parody = dom.SelectValue('//span[contains(text(),"Parodies:")]/following-sibling::a//span[contains(@class,"bad-f")]')
    info.Characters = dom.SelectValue('//span[contains(text(),"Characters:")]/following-sibling::a//span[contains(@class,"bad-f")]')
    info.Tags = dom.SelectValue('//span[contains(text(),"Tags:")]/following-sibling::a//span[contains(@class,"bad-f")]')
    info.Artist = dom.SelectValue('//span[contains(text(),"Artists:")]/following-sibling::a//span[contains(@class,"bad-f")]')
    info.Language = dom.SelectValue('//span[contains(text(),"Languages:")]/following-sibling::a//span[contains(@class,"bad-f")]')
    info.Circle = dom.SelectValue('//span[contains(text(),"Groups:")]/following-sibling::a//span[contains(@class,"bad-f")]')
    info.Type = dom.SelectValue('//span[contains(text(),"Categories:")]/following-sibling::a//span[contains(@class,"bad-f")]')

end

function GetPages()

    for thumbnailUrl in dom.SelectValues('//img[contains(@class,"img-thumbnail")]/@src') do

        local imageUrl = RegexReplace(thumbnailUrl, '\\/(\\d+)t\\.', '/$1.')

        pages.Add(imageUrl)

    end

end
