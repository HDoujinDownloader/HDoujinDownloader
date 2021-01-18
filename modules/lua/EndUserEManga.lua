function Register()

    -- "eManga" is a theme by EndUser (http://enduser.id).

    module.Name = 'eManga (EndUser)'
    module.Language = 'English'

    module.Domains.Add('kissmangas.com', 'KissManga')
    module.Domains.Add('manganelo.online', 'MangaNelo.online')
    module.Domains.Add('manganelo.today', 'MangaNelo.Today')
    module.Domains.Add('manganelos.com', 'MangaNelos.com')

end

function GetInfo()
   
    info.Title = CleanTitle(dom.SelectValue('//h1'))
    info.AlternativeTitle = dom.SelectValue('//span[contains(text(),"Alternative")]/following-sibling::text()[1]')
    info.Author = dom.SelectValue('//span[contains(text(),"Author")]/following-sibling::text()[1]')
    info.Artist = dom.SelectValue('//span[contains(text(),"Artist")]/following-sibling::text()[1]')
    info.Tags = dom.SelectValue('//span[contains(text(),"Genre")]/following-sibling::a')
    info.Type = dom.SelectValue('//span[contains(text(),"Type")]/following-sibling::text()[1]')
    info.DateReleased = dom.SelectValue('//span[contains(text(),"Release")]/following-sibling::text()[1]')
    info.Status = dom.SelectValue('//span[contains(text(),"Status")]/following-sibling::text()[1]')
    info.Summary = dom.SelectValue('//div[contains(@class,"manga-content")]')

end

function GetChapters()

    local chapterNodes = dom.SelectElements('(//div[contains(@class,"chapter-list")])[2]//h4')

    for chapterNode in chapterNodes do

        local chapter = ChapterInfo.New()

        chapter.Url = chapterNode.SelectValue('a/@href')
        chapter.Title = chapterNode.SelectValue('a') .. chapterNode.SelectValue('span')

        chapters.Add(chapter)

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValue('//p[@id="arraydata"]/text()'))

    pages.Referer = '' -- Hosts like mangapark.net 403 with a referer

end

function CleanTitle(title)

    return RegexReplace(tostring(title), ' Manga$', '')        

end
