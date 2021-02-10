-- "my Manga Reader CMS" is a paid CMS.
-- https://codecanyon.net/item/my-manga-reader-cms/12487949

function Register()

    module.Name = 'my Manga Reader CMS'

    -- English

    module = Module.New()

    module.Language = 'English'

    module.Domains.Add('readcomicsonline.ru', 'Read Comics Online')
    
    RegisterModule(module)

    -- Korean

    module = Module.New()

    module.Language = 'Korean'

    module.Domains.Add('manhwas.men', 'MANHWAS MEN')
    
    RegisterModule(module)

    -- Spanish

    module = Module.New()

    module.Language = 'Spanish'

    module.Domains.Add('mangas.in', 'Mangas.in')

    RegisterModule(module)

end

function GetInfo()

    info.Title = dom.SelectValue('//h2[contains(@class,"widget-title") or contains(@class,"listmanga-header")]')
    info.Status = dom.SelectValue('//div[contains(@class,"manga-name")]/a')
    info.Type = dom.selectValue('//dt[contains(text(), "Tipo") or contains(text(), "Type")]/following-sibling::dd')
    info.OriginalTitle = dom.selectValue('//dt[contains(text(), "Nombres")]/following-sibling::dd')
    info.AlternativeTitle = dom.selectValue('//dt[contains(text(), "Other names")]/following-sibling::dd')
    info.Author = dom.selectValue('//dt[contains(text(), "Autor")]/following-sibling::dd')
    info.Artist = dom.selectValue('//dt[contains(text(), "Artista")]/following-sibling::dd')
    info.DateReleased = dom.selectValue('//dt[contains(text(), "Publicación") or contains(text(), "Date of release")]/following-sibling::dd')
    info.Tags = dom.selectValues('//dt[contains(text(), "Género") or contains(text(), "Tags")]/following-sibling::dd//a')
    info.Adult = not isempty(dom.SelectValue('//i[contains(@class,"adult")]'))
    info.Summary = dom.SelectValues('//h5/following-sibling::p'):join('\n')

    if(isempty(info.Title)) then
        info.Title = dom.Title:before(' - ')
    end

    if(isempty(info.Title)) then
        info.Status = dom.SelectValue('//dt[contains(text(), "Status")]/following-sibling::dd') -- readcomicsonline.ru
    end

end

function GetChapters()

    for chapterNode in dom.SelectElements('//ul[contains(@class,"chapters")]//h5') do

        local chapterTitle = tostring(chapterNode)
        local chapterUrl = chapterNode.SelectValue('i/a/@href') -- manhwas.men

        if(isempty(chapterUrl)) then
            chapterUrl = chapterNode.SelectValue('a/@href')
        end

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    local baseUrl = tostring(dom):regex('base_url\\s*=\\s*\"([^"]+)', 1)
    local images = tostring(dom):regex('pages\\s*=\\s*(\\[[^]]+\\])', 1)

    local imagesJson = Json.New(images)

    -- mangas.in replaces the default base_url with their own CDN.

    if(module.Domain == 'mangas.in') then
        baseUrl = tostring(dom):regex("[^\\/]jQuery\\('\\.scan-page'\\)\\.attr\\('src',\\s*'([^']+)", 1)
    elseif(module.Domain == 'readcomicsonline.ru') then
        baseUrl = tostring(dom):regex("array\\.push\\('(.+?)'\\s*\\+\\s*pages", 1)
    end

    for image in Json.New(images) do

        local imageUrl = tostring(image['page_image'])

        -- On mangas.in, some content uses their own CDN, while some content uses an external CDN (like Blogspot).
        -- When an external CDN is used, the URL is obfuscated using EncodeURIComponent and then btoa.

        if(module.Domain == 'mangas.in' and tostring(image['external']) == '1') then
            imageUrl = DecodeUriComponent(DecodeBase64(imageUrl:after('//')))
        end

        pages.Add(GetRooted(imageUrl, GetRooted(baseUrl, url)))

    end

end
