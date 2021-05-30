function Register()

    module.Name = 'MangaPark'
    module.Language = 'English'

    module.Domains.Add('mangapark.net', 'MangaPark')
    module.Domains.Add('v2.mangapark.net', 'MangaPark')

    -- Set the "set" cookie so that 18+ content is visible.

    global.SetCookie('.' .. module.Domains.First(), "set", "h=1")

end

function GetInfo()

    info.AlternativeTitle = dom.SelectValue('//th[contains(text(), "Alternative")]/following-sibling::td'):split(';')
    info.Author = dom.SelectValues('//th[contains(text(), "Author(s)")]/following-sibling::*/a')
    info.Artist = dom.SelectValues('//th[contains(text(), "Artist(s)")]/following-sibling::*/a')
    info.Tags = dom.SelectValues('//th[contains(text(), "Genre(s)")]/following-sibling::*/a')
    info.Status = dom.SelectValue('//th[contains(text(), "Status")]/following-sibling::td')
    info.Summary = dom.SelectValue('//p[contains(@class, "summary")]')
  
    -- The "Type" metadata has the type followed by the reading direction.
    -- e.g. "Korean Manhwa - Read from left to right."

    local typeValue = dom.SelectValue('//th[contains(text(), "Type")]/following-sibling::td')

    info.Type = typeValue:before(' - ')
    info.ReadingDirection = typeValue:after(' - '):trim('.')

    -- The first case is for the reader, the second is for the summary.
    -- The reason we have it in this order is that the second will match for the reader, but the first won't match for the summary.

    info.Title = CleanTitle(dom.SelectValue('//h1'))

    if(isempty(info.Title)) then
        info.Title = CleanTitle(dom.SelectValue('//h2'))
    end

end

function GetChapters()
    
    -- Chapters are separated in groups ("versions" or "streams").

    local versionNodes = dom.SelectElements('//div[contains(@class, "stream")]')

    for i = 0, versionNodes.Count() - 1 do

        local versionName = versionNodes[i].SelectValue('.//span[contains(@class, "stream-text")]')
        local chapterNodes = versionNodes[i].SelectElements('.//div[a[contains(@class, "ch")]]')

        local versionChapters = ChapterList.New()

        for j = 0, chapterNodes.Count() - 1 do

            local chapterInfo = ChapterInfo.New()

            chapterInfo.Title = chapterNodes[j].SelectValue('a')
            chapterInfo.Url = chapterNodes[j].SelectValue('a/@href')
            chapterInfo.Version = versionName

            -- Some versions don't have the subtitle directly in the title, but in the following div.

            local chapterSubtitle = chapterNodes[j].SelectValue('following-sibling::div[contains(@class,"txt")]')

            if(not isempty(chapterSubtitle)) then
                chapterInfo.Title = chapterInfo.Title .. chapterSubtitle:trim()
            end

            versionChapters.Add(chapterInfo)

        end

        versionChapters.Reverse()

        chapters.AddRange(versionChapters)

    end

end

function GetPages()
    
    -- Strip the page number at the end to get "all pages" mode.

    url = RegexReplace(url, '\\/\\d+$', '')

    doc = http.Get(url)

    -- Pages are available from the "_load_pages" array.

    local arrayStr = doc:regex('_load_pages\\s*=\\s*(\\[.+?\\])', 1)
    local arrayJson = Json.New(arrayStr)

    pages.AddRange(arrayJson.SelectValues('[*].u'))

end

function CleanTitle(title)

    title = tostring(title)
        :beforelast(' - Page ')

    title = RegexReplace(title, '(?:Manhwa|Manga)$', '')

    return title

end
