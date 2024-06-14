-- The "Orbital" and "Blocksy" themes are near-identical variants.

function Register()

    module.Name = 'Asap'
    module.Language = 'pt'
    module.Adult = true

    module.Domains.Add('comics18.net', 'COMICSPORNO XXX')
    module.Domains.Add('comics18.org', 'Comics18')
    module.Domains.Add('comicsparaadultos.com', 'Comic Porno Erótico XXX')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Tags = dom.SelectValues('//div[contains(@class,"content-tags")]//a')

    if(isempty(info.Tags)) then
        info.Tags = dom.SelectValues('//div[contains(@class,"tagcloud")]//a')
    end

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"the-content")]//img/@src'))

    if(isempty(pages)) then -- Orbital
        pages.AddRange(dom.SelectValues('//div[contains(@class,"entry-content")]//p/img/@src'))
    end

    if(isempty(pages)) then -- Blocksy
        pages.AddRange(dom.SelectValues('//div[contains(@class,"entry-content")]//img/@data-src'))
    end

end
