function Register()

    module.Name = 'VerMangasPorno'
    module.Language = 'Spanish'
    module.Adult = true

    module.Domains.Add('vermangasporno.com', 'Ver Mangas Porno')
    module.Domains.Add('vercomicsporno.com', 'Ver Comics Porno')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Artist = info.Title:regex('^\\[([^\\\\]+)\\]', 1)
    info.Tags = dom.SelectValues('//div[contains(@id, "tagsin")]//a')

end

function GetPages()

    -- Using "//img" instead of "/img" is necessary, as some galleries have the images in a nested "p" tag.

    pages.AddRange(dom.SelectValues('//div[contains(@class, "comicimg")]//img/@data-src'))

end
