require "ViewComics"

function Register()

    module.Name = 'ComicExtra'
    module.Language = 'en'

    module.Domains.Add('comicextra.net')
    module.Domains.Add('comicextra.org')
    module.Domains.Add('comixextra.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Status = dom.SelectValue('//dt[contains(text(),"Status:")]/following-sibling::dd')
    info.AlternativeTitle = dom.SelectValue('//dt[contains(text(),"Alternate name:")]/following-sibling::dd')
    info.DateReleased = dom.SelectValue('//dt[contains(text(),"Released:")]/following-sibling::dd')
    info.Author = dom.SelectValue('//dt[contains(text(),"Author:")]/following-sibling::dd')
    info.Tags = dom.SelectValues('//dt[contains(text(),"Genres:")]/following-sibling::dd//a')
    info.Summary = dom.SelectValue('//div[contains(@id,"film-content")]')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//tbody[contains(@id,"list")]//a'))

    chapters.Reverse()

end
