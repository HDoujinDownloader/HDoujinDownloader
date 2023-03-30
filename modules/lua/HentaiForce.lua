function Register()

    module.Name = 'HentaiForce'
    module.Language = 'en'
    module.Adult = true

    module.Domains.Add('hentaiforce.net')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Parody = dom.SelectValues('//div[contains(text(),"Parodies:")]//a/text()[1]')
    info.Characters = dom.SelectValues('//div[contains(text(),"Characters:")]//a/text()[1]')
    info.Tags = dom.SelectValues('//div[contains(text(),"Tags:")]//a/text()[1]')
    info.Artist = dom.SelectValues('//div[contains(text(),"Artists:")]//a/text()[1]')
    info.Language = dom.SelectValues('//div[contains(text(),"Language:")]//a/text()[1]')
    info.Type = dom.SelectValues('//div[contains(text(),"Category:")]//a/text()[1]')

end

function GetPages()

    for imageUrl in dom.SelectValues('//div[contains(@id,"gallery-pages")]//img/@data-src') do

        imageUrl = RegexReplace(imageUrl, '(-\\d+)t', '$1')

        pages.Add(imageUrl)

    end

end
