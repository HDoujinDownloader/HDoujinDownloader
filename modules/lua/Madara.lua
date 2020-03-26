-- "Madara" is a commonly-used WordPress theme.
-- https://themeforest.net/item/madara-wordpress-theme-for-manga/20849828

function Register()

    module.Name = 'Madara'
    module.Language = 'English'

    module.Domains.Add('disasterscans.com', 'Disaster Scans')
    module.Domains.Add('porncomixonline.net', 'Porncomix')
    module.Domains.Add('toonily.com', 'Toonily')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1/text()[last()]')
    info.AlternativeTitle = dom.SelectValue('//div[contains(h5/text(), "Alternative")]/following-sibling::div')
    info.Author = dom.SelectValues('//div[contains(h5/text(), "Author(s)") or contains(h5/text(), "Auth.")]/following-sibling::div//a')
    info.Artist = dom.SelectValues('//div[contains(h5/text(), "Artist(s)") or contains(h5/text(), "Artist")]/following-sibling::div//a')
    info.Tags = dom.SelectValues('//div[contains(h5/text(), "Genre(s)") or contains(h5/text(), "Genres")]/following-sibling::div//a')
    info.Type = dom.SelectValue('//div[contains(h5/text(), "Type")]/following-sibling::div')
    info.DateReleased = dom.SelectValue('//div[contains(h5/text(), "Release")]/following-sibling::div')
    info.Status = dom.SelectValue('//div[contains(h5/text(), "Status")]/following-sibling::div')
    info.Summary = dom.SelectValue('//div[contains(@class, "description-summary")]')

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

    chapters.AddRange(dom.SelectElements('//div[contains(@class, "listing-chapters")]//li/a'))

    chapters.Reverse()

end

function GetPages()

    src = http.Get(url)

    -- Sometimes the images are stored in an array (www.porncomixonline.net).

    local imageArrayStr = src:regex('var\\s*chapter_preloaded_images\\s*=\\s*(\\[.+?\\])', 1)

    if(not isempty(imageArrayStr)) then

        pages.AddRange(Json.New(imageArrayStr))

    else

        pages.AddRange(dom.SelectValues('//div[contains(@class, "reading-content")]//img/@data-src'))

    end

end
