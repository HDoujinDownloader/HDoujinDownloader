-- MangaStarter is a WordPress theme.
-- https://www.codester.com/items/6001/mangastarter-build-a-manga-reader-with-wordpress

function Register()

    module.Name = 'MangaStarter'
    module.Language = 'Spanish'
    module.Adult = true

    module.Domains.Add('gntai.net', 'GNTAI.NET')
    module.Domains.Add('gntai.xyz', 'GNTAI.NET')

end

function GetInfo()

    info.Title = dom.SelectValue('//div[@id="reader"]//h1')
    info.Author = dom.SelectValue('//h2/a')
    info.Tags = dom.SelectValues('//div[contains(@class,"generos-tags")]/a')

end

function GetPages()

    local pagesArray = tostring(dom):regex('pages\\s*=\\s*(\\[.+?\\])', 1)
    local pagesJson = Json.New(pagesArray)

    pages.AddRange(pagesJson.SelectValues('[*].page_image'))

end
