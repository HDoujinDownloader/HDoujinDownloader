function Register()

    module.Name = 'MangaLife'
    module.Language = 'English'

    module.Domains.Add('manga4life.com')
    module.Domains.Add('mangalife.us')

end

function GetInfo()

    if(url:contains('/manga/')) then

        -- Added summary page.

        info.Title = dom.GetElementsByTagName('h1')[0]
        info.AlternativeTitle = dom.SelectValue('//li[descendant::span[contains(text(), "Alternate Name")]]')
        info.Author = dom.SelectValues('//li[descendant::span[contains(text(), "Author")]]/a/text()')
        info.Tags = dom.SelectValues('//li[descendant::span[contains(text(), "Genre")]]/a/text()')
        info.Type = dom.SelectValues('//li[descendant::span[contains(text(), "Type")]]/a/text()')
        info.DateReleased = dom.SelectValues('//li[descendant::span[contains(text(), "Released")]]/a/text()')
        info.Status = dom.SelectValue('//li[descendant::span[contains(text(), "Type")]]/a/text()')
        info.Summary = dom.SelectValue('//div[contains(@class, "Content")]')

    else

        -- Added chapter page.

        info.Title = FormatString('{0} Chapter {1}', doc:between('<title>', ' {'), GetChapterNumberFromUrl(url))
        info.PageCount = doc:between('"Page":"', '"')

    end

end

function GetChapters()

    doc = http.Get(url)

    local title = GetIndexName()
    local chaptersJson = Json.New(doc:regex('(?i)Chapters\\s*=\\s*(\\[.+?\\])', 1))

    for chapterJson in chaptersJson do

        -- Chapter URLs are of the the following form:
        -- <root>/read-online/<title>-chapter-<number>-page-1.html

        local chapterUrl = FormatString('/read-online/{0}{1}', title, ChapterUrlEncode(tostring(chapterJson['Chapter'])))
        local chapterName = FormatString('{0} {1}', chapterJson['Type'], GetChapterNumberFromUrl(chapterUrl))

        chapters.Add(chapterUrl, chapterName)

    end

    chapters.Reverse()

end

function GetPages()

    doc = http.Get(url)

    local title = GetIndexName()
    local currentChapterJson = Json.New(doc:regex('(?i)CurChapter\\s*=\\s*({.+?})', 1))
    local currentPathName = doc:regex('(?i)CurPathName\\s*=\\s*"(.+?)"', 1)
    local chapterNumber = tostring(currentChapterJson['Chapter']):sub(2, -2) -- "100010" -> "0001"
    local pageCount = tonumber(currentChapterJson['Page'])
 
    for i = 1, pageCount do

        -- Page URLs are of the following form:
        -- https://<currentPathName>/manga/<title>/<chapterNumber:0000>-<pageNumber:000>.png
        
        local pageUrl = FormatString(
            '//{0}/manga/{1}/{2}-{3:D2}.png', 
            currentPathName, 
            title, 
            chapterNumber, 
            i
        )
        
        pages.Add(pageUrl)

    end

end

function GetIndexName()

    return doc:regex('(?i)IndexName\\s*=\\s*"(.+?)"', 1)

end

function ChapterUrlEncode(e)

    -- This function is equivalent to the "vm.ChapterURLEncode" JS function.
    -- e.g. "100010" -> "-chapter-1-page-1.html"
    
    local pageOne = doc:regex('(?i)PageOne\\s*=\\s*"(.+?)"', 1)
    local indexNumber = tonumber(e:sub(1, 1)) -- first digit
    local chapterNumber = tonumber(e:sub(2, -2)) -- between first and last digits
    local fractionalNumber = tonumber(e:sub(-1)) -- last digit
    local index = (indexNumber != 1) and ('-index-'..indexNumber) or ''
    local fractional = (fractionalNumber != 0) and ('.'..fractionalNumber) or ''

    return FormatString(
        '-chapter-{0}{1}{2}{3}.html', 
        chapterNumber, 
        fractional, 
        index, 
        isempty(pageOne) and "-page-1" or pageOne
    )

end

function GetChapterNumberFromUrl(url)

    return url:regex('chapter-([\\d.]+)', 1)

end
