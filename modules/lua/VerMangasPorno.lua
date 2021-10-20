function Register()

    module.Name = 'VerMangasPorno'
    module.Language = 'Spanish'
    module.Adult = true

    module.Domains.Add('chochox.com', 'ChoChoX')
    module.Domains.Add('vcp.xxx', 'VCP XXX')
    module.Domains.Add('vercomicsporno.com', 'Ver Comics Porno')
    module.Domains.Add('vermangasporno.com', 'Ver Mangas Porno')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Artist = info.Title:regex('^\\[([^\\\\]+)\\]', 1)
    info.Tags = dom.SelectValues('//div[contains(@id, "tagsin")]//a')

    -- We may need to get the tags a little differently for some posts (chochox.com).

    if(isempty(info.Tags)) then
        info.Tags = dom.SelectValues('//a[@rel="tag"]')
    end

end

function GetPages()

    -- Using "//img" instead of "/img" is necessary, as some galleries have the images in a nested "p" tag.

    pages.AddRange(dom.SelectValues('//div[contains(@class, "comicimg")]//img/@data-src'))

    -- Update (May 12th, 2020): We need to use another way of getting images for newer posts.

    if(pages.Count() <= 0) then
        pages.AddRange(dom.SelectValues('//div[contains(@class, "comicimg")]//img/@data-lazy-src'))
    end

    -- We may need to get the tags a little differently for some posts (chochox.com).

    if(pages.Count() <= 0) then
       pages.AddRange(dom.SelectValues('//div[contains(@class, "wp-content")]//img/@src')) 
    end

end
