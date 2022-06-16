function Register()

    module.Name = 'MangaFreak'
    module.Language = 'English'

    module.Domains.Add('*.mangafreak.net')
    module.Domains.Add('mangafreak.net')
    module.Domains.Add('w12.mangafreak.net')
    module.Domains.Add('w13.mangafreak.net')

end

function GetInfo()

    local infoNode = dom.SelectElement('//div[contains(@class,"manga_series_data")]')

    info.Title = dom.SelectValue('//h5')
    info.AlternativeTitle = infoNode.SelectValue('text[1]')
    info.DateReleased = infoNode.SelectValue('div[1]')
    info.Status = infoNode.SelectValue('div[2]')
    info.Author = infoNode.SelectValue('div[3]')
    info.Artist = infoNode.SelectValue('div[4]')
    info.ReadingDirection = infoNode.SelectValue('div[5]')
    info.Tags = dom.SelectValues('//div[contains(@class,"series_sub_genre_list")]/a')
    info.Summary = dom.SelectValue('//p')

    if(isempty(info.Title)) then
        info.Title = CleanTitle(dom.SelectValue('//title'))
    end

end

function GetChapters()

   chapters.AddRange(dom.SelectElements('//div[contains(@class,"manga_series_list")]//a[not(@download)]')) 

end

function GetPages()

    pages.AddRange(dom.SelectValues('//img[@id="gohere"]/@src'))

end

function CleanTitle(title)

    return RegexReplace(tostring(title), '^Read|- MangaFreak$', '')
        :trim()

end
