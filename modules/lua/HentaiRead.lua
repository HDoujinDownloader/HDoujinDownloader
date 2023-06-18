-- HentaiRead uses a customized version of the Madara theme that shows page thumbnails instead of chapters.

function Register()

    module.Name = 'HentaiRead'
    module.Language = 'en'
    module.Adult = true

    module.Domains.Add('hentairead.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.OriginalTitle = dom.SelectValue('//h4')
    info.Language = dom.SelectValues('//span[contains(text(),"Language")]/following-sibling::span//a/span[contains(@class,"name")]')
    info.Type = dom.SelectValues('//span[contains(text(),"Category")]/following-sibling::span//a/span[contains(@class,"name")]')
    info.Circle = dom.SelectValues('//span[contains(text(),"Circle")]/following-sibling::span//a/span[contains(@class,"name")]')
    info.Parody = dom.SelectValues('//span[contains(text(),"Parody")]/following-sibling::span//a/span[contains(@class,"name")]')
    info.Tags = dom.SelectValues('//span[contains(text(),"Tags")]/following-sibling::span//a/span[contains(@class,"name")]')
    info.Scanlator = dom.SelectValues('//span[contains(text(),"Scanlator")]/following-sibling::span//a/span[contains(@class,"name")]')
    info.DateReleased = dom.SelectValues('//span[contains(text(),"Release Year")]/following-sibling::span//a/span[contains(@class,"name")]')

end

function GetPages()

    for imageUrl in dom.SelectValues('//div[contains(@class,"image-wrapper")]//img/@data-src') do

        imageUrl = imageUrl:before('&w=')
            :before('&amp;w=')

        pages.Add(imageUrl)

    end

end
