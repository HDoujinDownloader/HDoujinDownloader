function Register()

    module.Name = 'Manhwa Freak'
    module.Language = 'English'
    module.Adult = false

    module.Domains.Add('manhwafreak.com', 'Manhwa Freak')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Summary = dom.SelectValue('//div[contains(@id,"summary")]//p')
    info.AlternativeTitle = dom.SelectValue('//div[contains(@id,"info")]//p[contains(text(),"Alternative")]/following-sibling::p')
    info.DateReleased = dom.SelectValue('//div[contains(@id,"info")]//p[contains(text(),"Release")]/following-sibling::p')
    info.Author = dom.SelectValue('//div[contains(@id,"info")]//p[contains(text(),"Author(s)")]/following-sibling::p')
    info.Artist = dom.SelectValues('//div[contains(@id,"info")]//p[contains(text(),"Artist(s)")]/following-sibling::p')
    info.Tags = dom.SelectValues('//div[contains(@id,"info")]//p[contains(text(),"Genre(s)")]/following-sibling::p')
    info.Status = dom.SelectValue('//div[contains(@id,"info")]//p[contains(text(),"Status")]/following-sibling::p')
    info.Type = dom.SelectValue('//div[contains(@id,"info")]//p[contains(text(),"Type")]/following-sibling::p')
    info.Scanlator = 'Manhwa Freak'

end

function GetChapters()

    for chapterNode in dom.SelectElements('//div[contains(@class,"chapter-li")]//a') do

        local chapterUrl = chapterNode.SelectValue('@href')
        local chapterTitle = chapterNode.SelectValue('.//div[contains(@class,"chapter-info")]/p[(count(preceding-sibling::*)+1) = 1]')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[@id="readerarea"]//img/@data-src'))
    
    -- We need to extract pages from a script that should add them in the reader view

    if(isempty(pages)) then

        local mangaParameters = tostring(dom):regex('ts_reader.run\\(({.+?})\\);', 1)..';'
        local mangaJson = Json.New(mangaParameters)

        pages.AddRange(mangaJson['sources'][0]['images'])

    end
     
end