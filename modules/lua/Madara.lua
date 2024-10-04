-- "Madara" is a commonly-used WordPress theme.
-- https://themeforest.net/item/madara-wordpress-theme-for-manga/20849828

function Register()

    module.Name = 'Madara'

    module = module.New()

    module.Language = 'English'

    module.Domains.Add('1stkissmanga.io', '1ST KISS MANGA')
    module.Domains.Add('allporncomic.com', 'AllPornComic.com')
    module.Domains.Add('kunmanga.com', 'KunManga')
    module.Domains.Add('madaradex.org', 'MadaraDex')
    module.Domains.Add('manga18fx.com', 'Manga18fx')
    module.Domains.Add('manga18h.com', 'Manga18h')
    module.Domains.Add('manga18sx.com', 'Manga18SX')
    module.Domains.Add('mangaclash.com', 'Manga Clash')
    module.Domains.Add('mangadistrict.com', 'MANGA DISTRICT')
    module.Domains.Add('mangadna.com', 'MangaDNA')
    module.Domains.Add('mangalord.com', 'Manga Lord')
    module.Domains.Add('mangapl.com', 'MangaPL')
    module.Domains.Add('mangaqueen.net', 'Manga Queen')
    module.Domains.Add('mangastream.cc', 'MangaStream')
    module.Domains.Add('mangatx.com', 'Mangatx')
    module.Domains.Add('mangatx.to', 'Mangatx')
    module.Domains.Add('manhwa-raw.com', 'Manhwa-raw')
    module.Domains.Add('manytoon.club', 'ManyToon')
    module.Domains.Add('manytoon.com', 'ManyToon')
    module.Domains.Add('muctau.com', 'MUCTAU')
    module.Domains.Add('paragonscans.com', 'Paragonscans')
    module.Domains.Add('porncomixonline.net', 'Porncomix')
    module.Domains.Add('readfreecomics.com', 'ReadFreeComics')
    module.Domains.Add('skymanga.co', 'skymanga')
    module.Domains.Add('teenmanhua.com', 'teenmanhua.com')
    module.Domains.Add('toonclash.com', 'Manga Clash')
    module.Domains.Add('toongod.com', 'ToonGod')
    module.Domains.Add('toongod.org', 'ToonGod')
    module.Domains.Add('toonily.com', 'Toonily')
    module.Domains.Add('topmanhua.com', 'Top Manhua')
    module.Domains.Add('vinload.com', 'VinLoad')
    module.Domains.Add('webtoon.xyz', 'Webtoon XYZ')
    module.Domains.Add('www.toongod.com', 'ToonGod')
    module.Domains.Add('www.toongod.org', 'ToonGod')

    RegisterModule(module)

    module = module.New()

    module.Language = 'Arabic'

    module.Domains.Add('3asq.org', 'مانجا العاشق')
    module.Domains.Add('lekmanga.net', 'مانجا ليك')
    module.Domains.Add('like-manga.net', 'مانجا ليك')

    RegisterModule(module)

    module = module.New()

    module.Language = 'French'

    module.Domains.Add('epsilonscan.to', 'Epsilon Scan')

    RegisterModule(module)

    module = module.New()

    module.Language = 'Korean'

    module.Domains.Add('manhwaraw.com', 'ManhwaRaw')

    RegisterModule(module)

    module = module.New()

    module.Language = 'Portuguese'

    module.Domains.Add('neoxscans.net', 'NEOX Scanlator')
    module.Domains.Add('oldi.sussytoons.com', 'Sussy Scan')
    module.Domains.Add('sussyscan.com', 'Sussy Scan')
    module.Domains.Add('sussytoons.com', 'Sussy Scan')

    RegisterModule(module)

    module = module.New()

    module.Language = 'Spanish'

    module.Domains.Add('dragontranslation.net', 'DragonTranslation.net')
    module.Domains.Add('emperor-scan.com', 'Emperor Scan')
    module.Domains.Add('emperorscan.org', 'Emperor Scan')
    module.Domains.Add('kns.twobluescans.com', 'Lector KNS')
    module.Domains.Add('manhwa-latino.com', 'Manhwa-latino')
    module.Domains.Add('olympusscanlation.com', 'Olympus Scanlation')
    module.Domains.Add('seriesemperor.com', 'EmperorScan')

    RegisterModule(module)

    module = module.New()

    module.Language = 'Thai'

    module.Domains.Add('dokimori.com', 'DokiMori')
    module.Domains.Add('manga-post.com', 'Manga-Post')

    RegisterModule(module)

    module = module.New()

    module.Language = 'Turkish'

    module.Domains.Add('araznovel.com', 'ArazNovel')
    module.Domains.Add('mangawow.com', 'MangaWOW')
    module.Domains.Add('mangawow.net', 'MangaWOW')

    RegisterModule(module)

    module = module.New()

    module.Language = 'Vietnamese'

    module.Domains.Add('roadsteam.net', 'Roads Team')

    RegisterModule(module)

    -- Enable generic support for Madara websites.

    module.Domains.Add('*')

end

local function CheckGenericMatch()

    if(API_VERSION < 20240919) then
        return
    end

    if(not module.IsGeneric) then
        return
    end

    local isGenericMatch = dom.SelectNodes('//link[contains(@href,"/themes/madara/")]').Count() > 0 and
        dom.SelectNodes('//li[contains(@class,"wp-manga-chapter")]').Count() > 0

    if(not isGenericMatch) then
        Fail(Error.DomainNotSupported)
    end

end

local function CleanTitle(title)

    title = tostring(title)
        :beforelast(' - Webtoon ') -- Remove " - Webtoon Manhwa Hentai" suffix (manhwahentai.me)
        :beforelast(' &#8211; Webtoon ') -- Remove " — Webtoon Manhwa Hentai" suffix (manhwahentai.me)
        :trim()
        :trim(' Manhwa Hentai') -- Remove " Manhwa Hentai" suffix (manhwahentai.me)
        :trim()

    title = RegexReplace(title, '(?i)(?:español\\s*»\\s*manhwa-latino)$', '')

    return title

end

local function IsTagPage()

    -- There can be many different URLs for this depending on the type of tag page we're on.
    -- It's easier just to check the content of the page for the search navigation instead.

    return dom.SelectElements('//div[contains(@class,"tab-wrap")]').Count() > 0

end

function GetInfo()

    CheckGenericMatch()

    if(IsTagPage()) then

        -- Add all galleries on the current page to the download queue.

        for galleryUrl in dom.SelectValues('//div[contains(@id,"manga-item")]/a/@href') do
            Enqueue(galleryUrl)
        end

        info.Ignore = true

    else

        info.Title = dom.SelectValue('//h1/text()[last()]')
        info.AlternativeTitle = dom.SelectValue('//div[contains(h5/text(), "Alternative") or contains(h5/text(), "Diğer Adları") or contains(h5/text(), "Alternativo") or contains(h5/text(), "Nombre Alternativo")]/following-sibling::div')
        info.Author = dom.SelectValues('//div[contains(h5/text(), "Author(s)") or contains(h5/text(), "Auth.") or contains(h5/text(), "Yazar") or contains(h5/text(), "Autor(es)") or contains(h5/text(), "Autor/a") or contains(h5/text(), "الكاتب") or contains(h5/text(), "ผู้แต่ง")]/following-sibling::div//a')
        info.Artist = dom.SelectValues('//div[contains(h5/text(), "Artist") or contains(h5/text(), "Çizer") or contains(h5/text(), "Artista(s)") or contains(h5/text(), "الرسام") or contains(h5/text(), "คนวาด")]/following-sibling::div//a')
        info.Characters = dom.SelectValues('//div[contains(h5/text(), "Character")]/following-sibling::div//a')
        info.Parody = dom.SelectValues('//div[contains(h5/text(), "Parodi(es)")]/following-sibling::div//a')
        info.Circle = dom.SelectValues('//div[contains(h5/text(), "Circle")]/following-sibling::div//a')
        info.Tags = dom.SelectValues('(//div[contains(h5/text(), "Genre") or contains(h5/text(), "Tag(s)") or contains(h5/text(), "Kategori") or contains(h5/text(), "Tür") or contains(h5/text(), "Género(s)") or contains(h5/text(), "Genero(s)") or contains(h5/text(), "Generos") or contains(h5/text(), "التصنيفات") or contains(h5/text(), "หมวดหมู่")])[1]/following-sibling::div//a')
        info.Type = dom.SelectValue('//div[contains(h5/text(), "Type") or contains(h5/text(), "Tip") or contains(h5/text(), "Tipo") or contains(h5/text(), "النوع") or contains(h5/text(), "ประเภท")]/following-sibling::div')
        info.DateReleased = dom.SelectValue('//div[contains(h5/text(), "Release") or contains(h5/text(), "Yayınlanma") or contains(h5/text(), "سنة الإصدار")]/following-sibling::div')
        info.Status = dom.SelectValue('//div[contains(h5/text(), "Status") or contains(h5/text(), "Durum") or contains(h5/text(), "Estado") or contains(h5/text(), "الحالة")]/following-sibling::div')
        info.Summary = dom.SelectValues('//div[contains(@class, "description-summary") or contains(@class, "dsct") or contains(@class,"summary-text") or contains(@class,"summary-container") or contains(@class,"manga-excerpt")]//p'):join('\n\n') -- note that some content has multiple paragraphs (e.g. on astrallibrary.net)
        info.Adult = not isempty(dom.SelectValue('//h1/span[contains(@class, "adult")]'))
        info.Language = dom.SelectValues('//div[contains(h5/text(), "Language")]/following-sibling::div//a')
        info.Translator = dom.SelectValue('//div[contains(h5/text(), "فرق الترجمة")]/following-sibling::div//a')

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

        if(isempty(info.Summary)) then -- mg.mundodrama.site
            info.Summary = dom.SelectValue('//div[contains(@class,"manga-summary")]/p')
        end

        if(isempty(info.Language)) then

            -- Some sites have the language as part of the title (e.g. hmanhwa.com, "Title [Language]").

            info.Language = info.Title:trim():regex('\\[(.+?)\\]$', 1)

        end

        if(isempty(info.Tags)) then -- mm-scans.org
            info.Tags = dom.SelectValue('//div[h5[contains(text(),"Genre")]]/following-sibling::div')
        end

        if(isempty(info.Tags)) then -- mg.mundodrama.site
            info.Tags = dom.SelectValues('(//div[contains(@class,"genres-content")])[1]/a')
        end

        info.Title = CleanTitle(info.Title)

    end

end

function GetChapters()

    CheckGenericMatch()

    -- Sometimes chapters are grouped into volumes (e.g. araznovel.com).
    -- Note that it's possible to still have ungrouped chapters even when some chapters are grouped (#321).
    -- If both grouped and ungrouped chapters are present, the ungrouped chapters should be listed first.

    local volumeNodes = dom.SelectElements('//ul[contains(@class, "sub-chap")]')

    if(volumeNodes.Count() > 0) then

        -- Reselect the group nodes with the ungrouped node included.
        -- Subgroups are nested under the main group, so we need to be careful when selecting chapters to avoid duplicates.

        volumeNodes = dom.SelectElements('//ul[contains(@class, "sub-chap") or contains(@class,"main version-chap")]')

        -- We need to get them per-volume or else the ordering will be messed up.
        -- For example, Volume 1 might have Chapters 10 -> 1, and Volume 2 20 -> 11. We need to reverse each group separately.

        for i = 0, volumeNodes.Count() - 1 do

            local volumeNode = volumeNodes[i]
            local volumeName = volumeNode.SelectValue('./preceding-sibling::a')
            local volumeNumber = ''

            if(not isempty(volumeName)) then
                volumeNumber = volumeName:regex('\\d+')
            end

            local groupedChapters = ChapterList.New()

            groupedChapters.AddRange(volumeNode.SelectElements('li/a'))

            groupedChapters.Reverse()

            for j = 0, groupedChapters.Count() - 1 do

                local chapter = groupedChapters[j]

                if(chapter.Url:startswith('http')) then -- Ignore subgroups (they'll start with "javascript:").

                    chapter.Volume = volumeNumber

                    chapters.Add(chapter)

                end

            end

        end

    else

    -- Get all chapters.

    for node in dom.SelectElements('//div[contains(@class, "listing-chapters") or @id="chapterlist"]//li') do

        local chapterUrl = node.SelectValue('.//a/@href')

        -- Sometimes the chapter text contains extra information, such as the upload date (e.g. dragontranslation.net).
        -- Try to get the chapter title only.

        local chapterTitle = node.SelectValue('.//p[contains(@class,"chapter-manhwa-title")]')

        if(isempty(chapterTitle)) then
            chapterTitle = node.SelectValue('.//a')
        end

        if(isempty(chapterTitle)) then

            -- reset-scans.com

            chapterTitle = node.SelectValue('./div[contains(@class,"li__text")]/a')

        end

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

    end

end

function GetPages()

    CheckGenericMatch()

    local src = http.Get(url)

    -- Sometimes the images are stored in an array (www.porncomixonline.net).

    local imageArrayStr = src:regex('var\\s*chapter_preloaded_images\\s*=\\s*(\\[.+?\\])', 1)

    if(not isempty(imageArrayStr)) then

        pages.AddRange(Json.New(imageArrayStr))

    else

        -- Start by attempting to get the images from the src attribute.
        -- Note that we may get image URLs this way, but they're not guaranteed to be what we want (manhwatop.com).

        local possibleImageUrls = dom.SelectValues('//div[input[@id="wp-manga-current-chap"]]//img/@src')
        local imageUrlsAreValid = not (isempty(pages) or possibleImageUrls[0]:contains('/loader.svg') or possibleImageUrls[0]:contains('/wp-fastest-cache-premium/'))

        if(imageUrlsAreValid) then
            pages.AddRange(possibleImageUrls)
        end

        -- If the website uses the "WP Fastest Cache" plugin, we need to get the images from the "data-wpfc-original-src" attribute.

        if(isempty(pages)) then
            pages.AddRange(dom.SelectValues('//div[input[@id="wp-manga-current-chap"]]//img/@data-wpfc-original-src')) -- mangadistrict.com
        end

        -- Attempt to extract the images from the "data-src" attribute instead.

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

        if(isempty(pages)) then -- manga18fx.com
            pages.AddRange(dom.SelectValues('//div[contains(@class,"read-content")]//img/@src'))
        end

        if(isempty(pages)) then -- roadsteam.net
            pages.AddRange(dom.SelectValues('//div[contains(@class, "reading-content")]//img[@decoding]/@src'))
        end

        if(isempty(pages)) then -- manhwa-latino.com
            pages.AddRange(dom.SelectValues('//div[contains(@class,"read-container")]//img/@data-src'))
        end

        -- Sometimes the image URLs are in the "href" attribute under "entry-content" (Western comics on www.porncomixonline.net).
        -- This isn't part of the Madara theme, but it appears this site hasn't updated all of their galleries to use the Madara reader.
        -- e.g. https://www.porncomixonline.net/comicsbase/westerncomics/ (all galleries under this category)

        if(isempty(pages)) then
            pages.AddRange(dom.SelectValues('//div[contains(@class, "entry-content")]//figure/a/@href'))
        end

        -- Sometimes the image URLs are in the "<p></p>" tag (manhuaplus.com) due to manga type especially for "Video Chapter" or for another reason.
        if(isempty(pages)) then
            pages.AddRange(dom.SelectValues('//div[contains(@id, "chapter-video-frame") or contains(@class, "reading-content") or contains(@class, "blocks-gallery-grid")]//img/@src'))
        end

    end

    -- Fix broken image URLs (toonily.com).
    -- Some will have HTML entities that need to be decoded.

    for page in pages do
        page.Url = page.Url:replace('&#039;', '\'')
    end

end
