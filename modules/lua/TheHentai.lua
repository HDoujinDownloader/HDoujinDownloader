function Register()

    module.Name = 'The Hentai'
    module.Adult = true

    module.Domains.Add('*.thehentai.net')
    module.Domains.Add('en.thehentai.net')
    module.Domains.Add('thehentai.net')

end

function GetInfo()

    info.Title = dom.SelectValue('//div[contains(@class,"tituloPost")]')
    info.Artist = tostring(dom.SelectValues('//div[contains(@class,"tdArtista")]//a')):replace('@', '')
    info.Tags = tostring(dom.SelectValues('//div[contains(@class,"tdTags")][1]//a')):replace('#', '')
    info.Parody = tostring(dom.SelectValues('//div[contains(@class,"tdTags")]//a[contains(@href,"/parodia:")]')):replace('#', '')
    info.Characters = tostring(dom.SelectValues('//div[contains(@class,"tdTags")]//a[contains(@href,"/personagem:")]')):replace('#', '')
    info.Language = url:regex('\\/\\/(.{2})\\.', 1)
    info.Summary = dom.SelectValue('//div[contains(@class,"descricao")]')

    if(isempty(info.Language)) then
        info.Language = 'br'
    end

end

function GetPages()

    for thumbnailUrl in dom.SelectValues('//div[contains(@class,"post_imgs")]//img/@src') do

        local imageUrl = RegexReplace(thumbnailUrl, '-\\d+x\\d+', '')

        pages.Add(imageUrl)

    end

end
