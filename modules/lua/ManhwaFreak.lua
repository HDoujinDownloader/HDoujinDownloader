-- This website uses the same reader as Non Stop Scans (with some minor changes), so the code has been copied from there.
-- It's built with WordPress, and uses the "mangareaderfix" theme.

function Register()

    module.Name = 'Manhwa Freak'
    module.Language = 'English'
    module.Adult = false

    module.Domains.Add('freakcomic.com')
    module.Domains.Add('manhwa-freak.com')
    module.Domains.Add('manhwa-freak.org')
    module.Domains.Add('manhwafreak.com')

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

        local chapterUrl = chapterNode.SelectValue('./@href')
        local chapterTitle = chapterNode.SelectValue('.//p[1]')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    local json = Json.New(dom.SelectValue('//script[contains(text(),"ts_reader.run")]'):regex('ts_reader\\.run\\((.+?)\\);', 1))
    local defaultSource = json.SelectValue('defaultSource')
    local sourceJson = json.SelectToken("$.sources[?(@.source=='" .. defaultSource .. "')]")

    if(isempty(sourceJson)) then
        sourceJson = json.SelectToken('$.sources[0]')
    end

    for imageUrl in sourceJson.SelectValues('images[*]') do

        -- Avoid adding the loading spinner at the bottom of the page.
        
        if(not imageUrl:contains('/page-views-count/')) then
            pages.Add(imageUrl) 
        end

    end

end
