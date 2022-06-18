-- "Madara" is a commonly-used WordPress theme.
-- https://themeforest.net/item/madara-wordpress-theme-for-manga/20849828

function Register()

    module.Name = 'Madara'

    module = module.New()

    module.Language = 'English'

    module.Domains.Add('1stkissmanga.io', '1ST KISS MANGA')
    module.Domains.Add('allporncomic.com', 'AllPornComic.com')
    module.Domains.Add('hentairead.com', 'HentaiRead')
    module.Domains.Add('manga18fx.com', 'Manga18fx')
    module.Domains.Add('mangaclash.com', 'Manga Clash')
    module.Domains.Add('mangadna.com', 'MangaDNA')
    module.Domains.Add('mangalord.com', 'Manga Lord')
    module.Domains.Add('mangapl.com', 'MangaPL')
    module.Domains.Add('mangastream.cc', 'MangaStream')
    module.Domains.Add('mangatx.com', 'Mangatx')
    module.Domains.Add('manytoon.club', 'ManyToon')
    module.Domains.Add('manytoon.com', 'ManyToon')
    module.Domains.Add('muctau.com', 'MUCTAU')
    module.Domains.Add('porncomixonline.net', 'Porncomix')
    module.Domains.Add('readfreecomics.com', 'ReadFreeComics')
    module.Domains.Add('skymanga.co', 'skymanga')
    module.Domains.Add('teenmanhua.com', 'teenmanhua.com')
    module.Domains.Add('toonily.com', 'Toonily')
    module.Domains.Add('vinload.com', 'VinLoad')
    module.Domains.Add('webtoon.xyz', 'Webtoon XYZ')

    RegisterModule(module)

    module = module.New()
    module.Language = 'Korean'

    module.Domains.Add('manhwaraw.com', 'ManhwaRaw')

    module = module.New()
    module.Language = 'Portuguese'

    module.Domains.Add('neoxscans.net', 'NEOX Scanlator')
    
    RegisterModule(module)

    module = module.New()
    module.Language = 'Spanish'

    module.Domains.Add('nartag.com', 'Traducciones amistosas')
    module.Domains.Add('olympusscanlation.com', 'Olympus Scanlation')
    
    RegisterModule(module)

    module = module.New()
    module.Language = 'Thai'

    module.Domains.Add('dokimori.com', 'DokiMori')

    RegisterModule(module)

    module = module.New()
    module.Language = 'Turkish'

    module.Domains.Add('araznovel.com', 'ArazNovel')
    module.Domains.Add('mangawow.com', 'MangaWOW')
    module.Domains.Add('mangawow.net', 'MangaWOW')
    
    RegisterModule(module)

end

function GetInfo()

    info.Title = dom.SelectValue('//h1/text()[last()]')
    info.AlternativeTitle = dom.SelectValue('//div[contains(h5/text(), "Alternative") or contains(h5/text(), "Diğer Adları") or contains(h5/text(), "Alternativo")]/following-sibling::div')
    info.Author = dom.SelectValues('//div[contains(h5/text(), "Author(s)") or contains(h5/text(), "Auth.") or contains(h5/text(), "Yazar") or contains(h5/text(), "Autor(es)")]/following-sibling::div//a')
    info.Artist = dom.SelectValues('//div[contains(h5/text(), "Artist") or contains(h5/text(), "Çizer") or contains(h5/text(), "Artista(s)")]/following-sibling::div//a')
    info.Characters = dom.SelectValues('//div[contains(h5/text(), "Character")]/following-sibling::div//a')
    info.Parody = dom.SelectValues('//div[contains(h5/text(), "Parodi(es)")]/following-sibling::div//a')
    info.Circle = dom.SelectValues('//div[contains(h5/text(), "Circle")]/following-sibling::div//a')
    info.Tags = dom.SelectValues('(//div[contains(h5/text(), "Genre") or contains(h5/text(), "Tag(s)") or contains(h5/text(), "Kategori") or contains(h5/text(), "Tür") or contains(h5/text(), "Género(s)")])[1]/following-sibling::div//a')
    info.Type = dom.SelectValue('//div[contains(h5/text(), "Type") or contains(h5/text(), "Tip") or contains(h5/text(), "Tipo")]/following-sibling::div')
    info.DateReleased = dom.SelectValue('//div[contains(h5/text(), "Release") or contains(h5/text(), "Yayınlanma")]/following-sibling::div')
    info.Status = dom.SelectValue('//div[contains(h5/text(), "Status") or contains(h5/text(), "Durum")]/following-sibling::div')
    info.Summary = dom.SelectValues('//div[contains(@class, "description-summary") or contains(@class, "dsct")]//p'):join('\n\n') -- note that some content has multiple paragraphs (e.g. on astrallibrary.net)
    info.Adult = not isempty(dom.SelectValue('//h1/span[contains(@class, "adult")]'))
    info.Language = dom.SelectValues('//div[contains(h5/text(), "Language")]/following-sibling::div//a')

    if(module.GetName(url):endswith('Scans')) then
        info.Scanlator = module.GetName(url)
    end

    if(isempty(info.Title)) then

        -- Sometimes we need to get the title in a different way (www.porncomixonline.net).
        -- We purposefully look under the "post-title" div because, for western comics on the same website, "//h3" returns an incorrect title.
        -- This selector won't work for western comics (which are picked up in the following case), but does work for manga.

        info.Title = dom.SelectValue('//div[contains(@class, "post-title")]/h3')

    end

    if(isempty(info.Title)) then

        -- If the user added a reader URL, we may need to get the title in a different way (Western comics on www.porncomixonline.net).
        -- This case is not part of the Madara theme, but a special case for porncomixonline.net, where western comics use a notably different layout.

        info.Title = dom.SelectValue('//h2')
        info.Tags = dom.SelectValues('//div[@class="item-tags"]//li')

    end

    if(isempty(info.Title)) then

        -- Reader galleries don't always have a title, so we'll use the title of the selected chapter if we need to.

        info.Title = dom.SelectValue('//li[@class="active"]')

    end

    if(isempty(info.Summary)) then

        -- Some sites don't have a nested "p" element in the description (e.g. mangatx.com).

        info.Summary = dom.SelectValue('//div[contains(@class, "description-summary")]/div')

    end

    if(isempty(info.Summary)) then

        -- Some sites don't have a dedicated class for the description content (e.g. nartag.com).

        info.Summary = dom.SelectValue('//h5[contains(text(),"Summary")]/following-sibling::div')

    end

    if(isempty(info.Language)) then

        -- Some sites have the language as part of the title (e.g. hmanhwa.com, "Title [Language]").

        info.Language = info.Title:trim():regex('\\[(.+?)\\]$', 1)

    end

    info.Title = CleanTitle(info.Title)

end

function GetChapters()

    -- Sometimes chapters are grouped into volumes (araznovel.com).

    local volumeNodes = dom.SelectElements('//ul[contains(@class, "sub-chap")]')

    if(volumeNodes.Count() > 0) then

        -- We need to get them per-volume or else the ordering will be messed up.
        -- For example, Volume 1 might have Chapters 10 -> 1, and Volume 2 20 -> 11. We need to reverse each group separately.

        for i = 0, volumeNodes.Count() - 1 do

            local volumeNode = volumeNodes[i]

            local chapterList = ChapterList.New()

            chapterList.AddRange(volumeNode.SelectElements('li/a'))

            chapterList.Reverse()

            for j = 0, chapterList.Count() - 1 do
                chapters.Add(chapterList[j])
            end

        end

    else

        chapters.AddRange(dom.SelectElements('//div[contains(@class, "listing-chapters") or @id="chapterlist"]//li/a'))

        chapters.Reverse()

    end

end

function GetPages()

    src = http.Get(url)

    -- Sometimes the images are stored in an array (www.porncomixonline.net).

    local imageArrayStr = src:regex('var\\s*chapter_preloaded_images\\s*=\\s*(\\[.+?\\])', 1)

    if(not isempty(imageArrayStr)) then

        pages.AddRange(Json.New(imageArrayStr))

    else

        -- Start by attempting to get the images from the src attribute.
        -- Note that we may get image URLs this way, but they're not guaranteed to be what we want (manhwatop.com).

        local possibleImageUrls = dom.SelectValues('//div[input[@id="wp-manga-current-chap"]]//img/@src')
        local imageUrlsAreValid = not (isempty(pages) or possibleImageUrls[0]:contains('/loader.svg'))

        if(imageUrlsAreValid) then
            pages.AddRange(possibleImageUrls)
        end

        -- Attempt to extract the images from the data-src attribute instead.

        if(isempty(pages)) then
            pages.AddRange(dom.SelectValues('//div[input[@id="wp-manga-current-chap"]]//img/@data-src')) -- webtoon.xyz
        end

        -- This method works for most sites, but it can potentially match undesired divs ("reading-content-wrap", "related-reading-wrap") (dokimori.com).

        if(isempty(pages)) then
            pages.AddRange(dom.SelectValues('//div[contains(@class, "reading-content")]//img/@data-src'))
        end
        
        -- Sometimes the image URLs are in the "src" attribute (mangawow.com).
        -- We get images with the "id" attribute specifically, because some sites have ad images (manytoon.club, readfreecomics.com).

        if(isempty(pages)) then
            pages.AddRange(dom.SelectValues('//div[contains(@class, "reading-content")]//img[@id]/@src'))
        end

        if(isempty(pages)) then
            pages.AddRange(dom.SelectValues('//div[contains(@class,"read-content")]//img/@src')) -- manga18fx.com
        end

        -- Sometimes the image URLs are in the "href" attribute under "entry-content" (Western comics on www.porncomixonline.net).
        -- This isn't part of the Madara theme, but it appears this site hasn't updated all of their galleries to use the Madara reader.
        -- e.g. https://www.porncomixonline.net/comicsbase/westerncomics/ (all galleries under this category)

        if(isempty(pages)) then
            pages.AddRange(dom.SelectValues('//div[contains(@class, "entry-content")]//figure/a/@href'))
        end

    end

end

function CleanTitle(title)

    return tostring(title)
        :beforelast(' - Webtoon ') -- Remove " - Webtoon Manhwa Hentai" suffix (manhwahentai.me)
        :beforelast(' &#8211; Webtoon ') -- Remove " — Webtoon Manhwa Hentai" suffix (manhwahentai.me)
        :trim()
        :trim(' Manhwa Hentai') -- Remove " Manhwa Hentai" suffix (manhwahentai.me)
        :trim()

end
