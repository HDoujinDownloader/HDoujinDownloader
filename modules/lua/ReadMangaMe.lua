function Register()

    module.Name = 'ReadManga.Me'

    module.Language = 'Russian'

    module.Domains.Add('allhen.online', 'AllHentai')
    module.Domains.Add('mintmanga.live', 'MintManga')
    module.Domains.Add('readmanga.io', 'ReadManga')
    module.Domains.Add('readmanga.live', 'ReadManga')
    module.Domains.Add('readmanga.me', 'ReadManga')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1/span[contains(@class, "name")]')
    info.Type = dom.SelectValue('(//h1/text())[1]')
    info.AlternativeTitle = dom.SelectValue('//h1/span[contains(@class, "eng-name")]')
    info.Tags = dom.SelectValues('//span[contains(@class, "elem_genre") or contains(@class, "elem_tag")]')
    info.Author = dom.SelectValues('//span[contains(@class, "elem_author")]')
    info.Artist = dom.SelectValues('//span[contains(@class, "elem_illustrator")]')
    info.DateReleased = dom.SelectValue('//span[contains(@class, "elem_year")]')
    info.Publisher = dom.SelectValues('//span[contains(@class, "elem_magazine")]')
    info.Translator = dom.SelectValues('//span[contains(@class, "elem_translator")]')
    info.Summary = dom.SelectValue('//div[contains(@class, "manga-description")]')

    if(isempty(info.Title)) then

        -- If a chapter URL was added, we'll need to get the title a different way.

        info.Title = CleanTitle(dom.SelectValue('//h1'))

    end

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//div[contains(@id,"chapters-list")]//a'))

    chapters.Reverse()

end

function GetPages()

    -- Set the "mtr" parameter, which is required for accessing certain chapters.
    -- e.g. /rainbow/vol15/153

    url = SetParameter(url, 'mtr', 'true')
    dom = Dom.New(http.Get(url))

    -- Pages are located in array passed to "rm_h.init" or "rm_h.initReader".
    -- Each item is a tuple consisting of the host and the path for each image.

    local imagesScript = dom.SelectValue('//script[contains(text(),"readerInit")]')
    local imagesArray = imagesScript:regex('rm_h\\.(?:init|initReader|readerDoInit)\\(.*?(\\[\\[.+?\\]\\])', 1)

    for jsonToken in Json.New(imagesArray) do

        local root = tostring(jsonToken[0])
        local path = tostring(jsonToken[2])

        if(root:startsWith('//')) then
            root = GetRooted(root, url)
        end

        if(root:startswith('http')) then
            pages.Add(root .. path)
        end

    end

end

function CleanTitle(title)

    return tostring(title)
        :before(' Read manga ')

end
