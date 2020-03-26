function Register()

    module.Name = 'ReadManga.Me'

    module.Language = 'Russian'

    module.Domains.Add('readmanga.me', 'ReadManga.me')
    module.Domains.Add('mintmanga.live', 'MintManga.com')

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

    chapters.AddRange(dom.SelectElements('//div[contains(@class, "chapters-link")]//a'))

    chapters.Reverse()

end

function GetPages()

    -- Set the "mature" parameter, which is required for accessing certain chapters.
    -- e.g. https://mintmanga.live/rainbow/vol15/153

    if(isempty(GetParameter(url, 'mature'))) then
        url = SetParameter(url, 'mature', '1')
    end

    src = http.Get(url)

    -- Pages are located in array passed to "rm_h.init".

    local arrayJson = Json.New(src:regex('rm_h\\.init\\(\\s*(\\[.+?\\]\\])', 1))

    for jsonToken in arrayJson do
        pages.Add(tostring(jsonToken[0]) .. tostring(jsonToken[2]))
    end

end

function CleanTitle(title)

    return tostring(title)
        :before(' Read manga ')

end
