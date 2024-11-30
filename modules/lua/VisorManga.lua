function Register()

    module.Name = 'Visor TMO Manga'
    module.Language = 'Spanish'
    module.Adult = false

    module.Domains.Add('visormanga.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Tags = dom.SelectValues('//span[contains(@class,"genres-title-manga")]//following-sibling::a')
    info.Summary = dom.SelectValue('//span[contains(@class,"sinopsis-manga")]/following-sibling::p')
    info.DateReleased = info.Title:regex('\\((\\d+)\\)', 1)

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//li[contains(@class,"manga-chapter")]//a'))

    chapters.Reverse()

end

function GetPages()
    pages.AddRange(dom.SelectValues('//div[@id="image-alls"]//img/@data-src'))
end
