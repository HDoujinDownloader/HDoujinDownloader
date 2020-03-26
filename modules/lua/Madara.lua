-- "Madara" is a commonly-used WordPress theme.
-- https://themeforest.net/item/madara-wordpress-theme-for-manga/20849828

function Register()

    module.Name = 'Madara'

    module = module.New()

    module.Language = 'English'

    module.Domains.Add('disasterscans.com', 'Disaster Scans')
    module.Domains.Add('porncomixonline.net', 'Porncomix')
    module.Domains.Add('toonily.com', 'Toonily')

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
    info.Tags = dom.SelectValues('//div[contains(h5/text(), "Genre") or contains(h5/text(), "Kategori") or contains(h5/text(), "Tür")]/following-sibling::div//a')
    info.Type = dom.SelectValue('//div[contains(h5/text(), "Type") or contains(h5/text(), "Tip")]/following-sibling::div')
    info.DateReleased = dom.SelectValue('//div[contains(h5/text(), "Release") or contains(h5/text(), "Yayınlanma")]/following-sibling::div')
    info.Status = dom.SelectValue('//div[contains(h5/text(), "Status") or contains(h5/text(), "Durum")]/following-sibling::div')
    info.Summary = dom.SelectValue('//div[contains(@class, "description-summary")]//p')
    info.Adult = not isempty(dom.SelectValue('//h1/span[contains(@class, "adult")]'))

    if(module.GetName(url):endswith('Scans')) then
        info.Scanlator = module.GetName(url)
    end

    -- Sometimes we need to get the title in a different way (www.porncomixonline.net).

    if(isempty(info.Title)) then
        info.Title = dom.SelectValue('//h3')
    end

    -- Reader galleries don't always have a title, so we'll use the title of the selected chapter (www.porncomixonline.net).

    if(isempty(info.Title)) then
        info.Title = dom.SelectValue('//li[@class="active"]')
    end

end

function GetChapters()

    -- Sometimes chapters are grouped into volumes (araznovel.com).

    local volumeNodes = dom.SelectElements('//ul[contains(@class, "sub-chap")]')

    if(volumeNodes.Count() > 0) then

        -- We need to get them per-volume or else the ordering will be messed up.
        -- For example, Volume 1 might have Chapters 10 -> 1, and Volume 2 20 -> 11.
        -- We need to reverse each group separately.

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

        pages.AddRange(dom.SelectValues('//div[contains(@class, "reading-content")]//img/@data-src'))

        -- Sometimes the image URLs are in "src" instead of "data-src" (mangawow.com).

        if(pages.Count() <= 0) then
            pages.AddRange(dom.SelectValues('//div[contains(@class, "reading-content")]//img/@src'))
        end

    end

end
