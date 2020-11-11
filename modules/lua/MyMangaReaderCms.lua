-- "my Manga Reader CMS" is a paid CMS.
-- https://codecanyon.net/item/my-manga-reader-cms/12487949

function Register()

    module.Name = 'my Manga Reader CMS'

    -- Spanish

    module = Module.New()

    module.Language = 'Spanish'

    module.Domains.Add('mangas.in', 'Mangas.in')

    RegisterModule(module)

end

function GetInfo()

    info.Title = dom.SelectValue('//h2')
    info.Status = dom.SelectValue('//div[contains(@class,"manga-name")]/a')
    info.Type = dom.selectValue('//dt[contains(text(), "Tipo")]/following-sibling::dd')
    info.OriginalTitle = dom.selectValue('//dt[contains(text(), "Nombres")]/following-sibling::dd')
    info.Author = dom.selectValue('//dt[contains(text(), "Autor")]/following-sibling::dd')
    info.Artist = dom.selectValue('//dt[contains(text(), "Artista")]/following-sibling::dd')
    info.DateReleased = dom.selectValue('//dt[contains(text(), "Publicación")]/following-sibling::dd')
    info.Tags = dom.selectValues('//dt[contains(text(), "Género")]/following-sibling::dd//a')
    info.Adult = not isempty(dom.SelectValue('//i[contains(@class,"adult")]'))

    if(isempty(info.Title)) then
        info.Title = dom.Title:before(' - ')
    end

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//ul[contains(@class,"chapters")]//i/a'))

end

function GetPages()

    local baseUrl = tostring(dom):regex('base_url\\s*=\\s*\"([^"]+)', 1)
    local images = tostring(dom):regex('pages\\s*=\\s*(\\[[^]]+\\])', 1)

    -- mangas.in replaces the default base_url with their own CDN.

    if(module.Domain == 'mangas.in') then
        baseUrl = tostring(dom):regex("[^\\/]jQuery\\('\\.scan-page'\\)\\.attr\\('src',\\s*'([^']+)", 1)
    end

    baseUrl = baseUrl:trim('/')
    
    for image in Json.New(images).SelectValues('[*].page_image') do
        pages.Add(baseUrl..'/'..image)
    end

end
