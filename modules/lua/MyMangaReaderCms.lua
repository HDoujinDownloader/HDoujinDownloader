-- "my Manga Reader CMS" is a paid CMS.
-- https://codecanyon.net/item/my-manga-reader-cms/12487949

function Register()

    module.Name = 'my Manga Reader CMS'

    -- English

    module = Module.New()

    module.Language = 'English'

    module.Domains.Add('hentaishark.com', 'Hentai Shark')
    module.Domains.Add('readcomicsonline.ru', 'Read Comics Online')
    module.Domains.Add('readhent.ai', 'ReadHentai')
    module.Domains.Add('www.hentaishark.com', 'Hentai Shark')

    RegisterModule(module)

    -- Turkish

    module = Module.New()

    module.Language = 'Turkish'

    module.Domains.Add('mangadenizi.com', 'MangaDenizi')

    RegisterModule(module)

end

local function CleanTitle(title)
    return RegexReplace(title, '(?:^(?:\\s*↛\\s*)|(?:\\:\\s*)$)', '')
end

local function IsBase64Encoded(str)
    return #str % 4 == 0 and Regex.IsMatch(str, "^[A-Za-z0-9+/]+={0,2}$")
end

function GetInfo()

    info.Title = dom.SelectValue('//h2[contains(@class,"widget-title") or contains(@class,"listmanga-header")]')
    info.Status = dom.SelectValue('//div[contains(@class,"manga-name")]/a')
    info.Type = dom.SelectValue('//dt[contains(text(), "Tipo") or contains(text(), "Type") or contains(text(), "Categories")]/following-sibling::dd')
    info.OriginalTitle = dom.SelectValue('//dt[contains(text(), "Nombres")]/following-sibling::dd')
    info.AlternativeTitle = dom.SelectValue('//dt[contains(text(), "Other names") or contains(text(), "Diğer Adları")]/following-sibling::dd')
    info.Author = dom.SelectValue('//dt[contains(text(), "Autor") or contains(text(), "Yazar")]/following-sibling::dd')
    info.Artist = dom.SelectValue('//dt[contains(text(), "Artista") or contains(text(), "Sanatçı") or contains(text(), "Artists")]/following-sibling::dd')
    info.DateReleased = dom.SelectValue('//dt[contains(text(), "Publicación") or contains(text(), "Date of release") or contains(text(), "Yayınlanma Tarihi")]/following-sibling::dd')
    info.Tags = dom.SelectValues('//dt[contains(text(), "Género") or contains(text(), "Tags") or contains(text(), "Kategoriler") or contains(text(), "Etiketler")]/following-sibling::dd//a/text()[1]')
    info.Adult = not isempty(dom.SelectValue('//i[contains(@class,"adult")]'))
    info.Summary = dom.SelectValues('//h5/following-sibling::p'):join('\n')
    info.Parody = dom.SelectValue('//dt[contains(text(), "Parodies")]/following-sibling::dd[1]/a')
    info.Characters = dom.SelectValue('//dt[contains(text(), "Characters")]/following-sibling::dd[1]/a')
    info.Language = dom.SelectValue('//dt[contains(text(), "Languages")]/following-sibling::dd[1]/a')

    if(isempty(info.AlternativeTitle)) then
        info.AlternativeTitle = dom.SelectValue('//h3[contains(@class,"widget-title")]') -- hentaishark.com
    end

    if(isempty(info.Status)) then
        info.Status = dom.SelectValue('//dt[contains(text(), "Status") or contains(text(), "Durum")]/following-sibling::dd') -- mangadenizi.com, manhwas.men, readcomicsonline.ru, ...
    end

    if(isempty(info.Title)) then
        info.Title = dom.Title:before(' - ')
    end

end

function GetChapters()

    for chapterNode in dom.SelectElements('//ul[contains(@class,"chapters")]//h5') do

        local chapterTitle = CleanTitle(tostring(chapterNode))
        local chapterUrl = chapterNode.SelectValue('i/a/@href') -- manhwas.men

        if(isempty(chapterUrl)) then
            chapterUrl = chapterNode.SelectValue('a/@href')
        end

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    local scriptContent = dom.SelectValue('//script[contains(text(),"base_url")]')

    local baseUrl = scriptContent:regex('base_url\\s*=\\s*\"([^"]+)', 1)
    local images = scriptContent:regex('pages\\s*=\\s*(\\[[^]]+\\])', 1)

    -- Some domains replace the base_url value with their own CDN.

    local alternativeBaseUrl1 = scriptContent:regex("[^\\/]jQuery\\('\\.scan-page'\\)\\.attr\\('src',\\s*'([^']+)", 1)
    local alternativeBaseUrl2 = scriptContent:regex("array\\.push\\('(.+?)'\\s*\\+\\s*pages", 1)

    if(not isempty(alternativeBaseUrl1)) then
        baseUrl = alternativeBaseUrl1
    elseif(not isempty(alternativeBaseUrl2)) then
        baseUrl = alternativeBaseUrl2
    end

    for image in Json.New(images) do

        local imageUrl = tostring(image['page_image'])

        -- On mangas.in, some content uses their own CDN, while some content uses an external CDN (like Blogspot).
        -- When an external CDN is used, the URL is obfuscated using EncodeURIComponent and then btoa.

        if(tostring(image['external']) == '1' and IsBase64Encoded(imageUrl:after('//'))) then
            imageUrl = DecodeUriComponent(DecodeBase64(imageUrl:after('//')))
        end

        pages.Add(GetRooted(imageUrl, GetRooted(baseUrl, url)))

    end

end
