-- "tema-fotos" is a WordPress theme.

function Register()

    module.Name = 'Tema Fotos'
    module.Language = 'Portuguese (Brazil)'
    module.Adult = true

    module.Domains.Add('comicsmanics.com', 'ComicsManiacs')
    module.Domains.Add('freeadultcomix.com', 'FreeAdultComix')

end

function GetInfo()

    info.Title = dom.SelectValue('//h2')
    info.Summary = dom.SelectValue('//div[contains(@class,"post-texto")]/p')
    info.Tags = dom.SelectValues('//div[contains(@class,"post-tags")]//a')
    info.Parody = info.Summary:regex('Parody:(.+?)[–.]', 1)
    info.Characters = info.Summary:regex('Character:(.+?)[–.]', 1)

end

function GetPages()

    pages.AddRange(dom.SelectValues('//figure/a/@href'))

    -- comicsmanics.com

    if(pages.Empty()) then
        pages.AddRange(dom.SelectValues('//div[contains(@class,"post-texto")]//img/@src'))
    end

end
