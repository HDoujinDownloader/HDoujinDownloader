function Register()

    module.Name = 'MangaFreak'
    module.Language = 'English'

    module.Domains.Add('*.mangafreak.me')
    module.Domains.Add('*.mangafreak.net')
    module.Domains.Add('mangafreak.net')
    module.Domains.Add('w12.mangafreak.net')
    module.Domains.Add('w13.mangafreak.net')
    module.Domains.Add('w14.mangafreak.net')
    module.Domains.Add('w15.mangafreak.net')

end

local function CleanTitle(title)

    return RegexReplace(tostring(title), '^Read|- MangaFreak$', '')
        :trim()

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.AlternativeTitle = dom.SelectValue('//h1/following-sibling::div')
    info.DateReleased = dom.SelectValue('//div[contains(text(),"Release:")]'):after(":")
    info.Status = dom.SelectValue('//div[contains(text(),"Status:")]'):after(":")
    info.Author = dom.SelectValue('//div[contains(text(),"Author:")]'):after(":")
    info.Artist = dom.SelectValue('//div[contains(text(),"Artist:")]'):after(":")
    info.ReadingDirection = dom.SelectValue('//div[contains(text(),"Type:")]'):after(":")
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
