-- Mangamainac is a WordPress theme.
-- https://www.themedetect.com/Theme/mangamainac

function Register()

    module.Name = 'mangamainac'
    module.Language = 'English'
    module.Type = 'Manga'
    module.Adult = false

    module.Domains.Add('readshingekinokyojin.com', 'Read Shingeki no kyojin Manga Online')

end

local function CleanTitle(title) 

    title = tostring(title):trim()

    return RegexReplace(title, '^Read|Manga(?: Online)?$', '')

end

function GetInfo()

    info.Title = CleanTitle(dom.SelectValue('//h1'))
    info.Author = dom.SelectValue('(//*[*[contains(text(),"Author(s)")]]/following-sibling::text())[1]')
    info.DateReleased = dom.SelectValue('(//*[*[contains(text(),"Released")]]/following-sibling::text())[1]')
    info.Tags = dom.SelectValue('(//*[*[contains(text(),"Genre(s)")]]/following-sibling::text())[1]'):split(',')
    info.Status = dom.SelectValue('(//*[*[contains(text(),"Status")]]/following-sibling::text())[1]'):split(' ')[0]
    info.Description = dom.SelectValue('(//*[*[contains(text(),"Description")]]/following-sibling::text())[1]')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//ul[contains(@class,"maniac_posts")]//a'))

    chapters.Reverse()

end

function GetPages()

    for pageUrl in dom.SelectValues('//div[contains(@class,"img_container")]//img/@src') do
        pages.Add(pageUrl)
    end

end
