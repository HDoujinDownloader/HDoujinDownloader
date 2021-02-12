-- "Madara" is a commonly-used WordPress theme.
-- https://themeforest.net/item/madara-wordpress-theme-for-manga/20849828

function Register()

    module.Name = 'Madara'

    module = module.New()

    module.Language = 'English'

    module.Domains.Add('disasterscans.com', 'Disaster Scans')
    module.Domains.Add('hentairead.com', 'HentaiRead')
    module.Domains.Add('mangapl.com', 'MangaPL')
    module.Domains.Add('mangastream.cc', 'MangaStream')
    module.Domains.Add('mangatx.com', 'Mangatx')
    module.Domains.Add('manhwahentai.me', 'ManhwaHentai.me')
    module.Domains.Add('manytoon.club', 'ManyToon')
    module.Domains.Add('manytoon.com', 'ManyToon')
    module.Domains.Add('porncomixonline.net', 'Porncomix')
    module.Domains.Add('readfreecomics.com', 'ReadFreeComics')
    module.Domains.Add('toonily.com', 'Toonily')
    module.Domains.Add('webtoon.xyz', 'Webtoon XYZ')

    RegisterModule(module)

    module = module.New()

    module.Language = 'Korean'

    module.Domains.Add('manhwaraw.com', 'ManhwaRaw')

    RegisterModule(module)

    module = module.New()

    module.Language = 'Thai'

    module.Domains.Add('dokimori.com', 'DokiMori')

    RegisterModule(module)

    module = module.New()

    module.Language = 'Turkish'

    module.Domains.Add('araznovel.com', 'ArazNovel')
    module.Domains.Add('mangawow.com', 'MangaWOW')
    
    RegisterModule(module)

end

function GetInfo()

    info.Title = dom.SelectValue('//h1/text()[last()]')
    info.AlternativeTitle = dom.SelectValue('//div[contains(h5/text(), "Alternative") or contains(h5/text(), "Diğer Adları")]/following-sibling::div')
    info.Author = dom.SelectValues('//div[contains(h5/text(), "Author(s)") or contains(h5/text(), "Auth.") or contains(h5/text(), "Yazar")]/following-sibling::div//a')
    info.Artist = dom.SelectValues('//div[contains(h5/text(), "Artist") or contains(h5/text(), "Çizer")]/following-sibling::div//a')
    info.Characters = dom.SelectValues('//div[contains(h5/text(), "Character")]/following-sibling::div//a')
    info.Parody = dom.SelectValues('//div[contains(h5/text(), "Parodi(es)")]/following-sibling::div//a')
    info.Circle = dom.SelectValues('//div[contains(h5/text(), "Circle")]/following-sibling::div//a')
    info.Tags = dom.SelectValues('(//div[contains(h5/text(), "Genre") or contains(h5/text(), "Tag(s)") or contains(h5/text(), "Kategori") or contains(h5/text(), "Tür")])[1]/following-sibling::div//a')
    info.Type = dom.SelectValue('//div[contains(h5/text(), "Type") or contains(h5/text(), "Tip")]/following-sibling::div')
    info.DateReleased = dom.SelectValue('//div[contains(h5/text(), "Release") or contains(h5/text(), "Yayınlanma")]/following-sibling::div')
    info.Status = dom.SelectValue('//div[contains(h5/text(), "Status") or contains(h5/text(), "Durum")]/following-sibling::div')
    info.Summary = dom.SelectValues('//div[contains(@class, "description-summary")]//p'):join('\n\n') -- note that some content has multiple paragraphs (e.g. on astrallibrary.net)
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

        chapters.AddRange(dom.SelectElements('//div[contains(@class, "listing-chapters")]//li/a'))

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

        pages.AddRange(dom.SelectValues('//div[input[@id="wp-manga-current-chap"]]//img/@src'))

        -- This method works for most sites, but it can potentially match undesired divs ("reading-content-wrap", "related-reading-wrap") (dokimori.com).

        if(pages.Count() <= 0) then
            pages.AddRange(dom.SelectValues('//div[contains(@class, "reading-content")]//img/@data-src'))
        end
        
        -- Sometimes the image URLs are in the "src" attribute (mangawow.com).
        -- We get images with the "id" attribute specifically, because some sites have ad images (manytoon.club, readfreecomics.com).

        if(pages.Count() <= 0) then
            pages.AddRange(dom.SelectValues('//div[contains(@class, "reading-content")]//img[@id]/@src'))
        end

        -- Sometimes the image URLs are in the "href" attribute under "entry-content" (Western comics on www.porncomixonline.net).
        -- This isn't part of the Madara theme, but it appears this site hasn't updated all of their galleries to use the Madara reader.
        -- e.g. https://www.porncomixonline.net/comicsbase/westerncomics/ (all galleries under this category)

        if(pages.Count() <= 0) then
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
