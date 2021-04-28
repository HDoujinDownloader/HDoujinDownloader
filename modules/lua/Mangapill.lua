function Register()

    module.Name = 'Mangapill'
    module.Language = 'English'
    module.Adult = false

    module.Domains.Add('mangapill.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.AlternativeTitle = dom.SelectValue('//h1/following-sibling::div')
    info.Summary = dom.SelectValue('//p')
    info.Tags = dom.SelectValues('//h5[contains(text(),"Genres")]/following-sibling::a')
    info.Type = dom.SelectValue('//h5[contains(text(),"Type")]/following-sibling::div')
    info.Status = dom.SelectValue('//h5[contains(text(),"Status")]/following-sibling::div')
    info.DateReleased = dom.SelectValue('//h5[contains(text(),"Publishing Year")]/following-sibling::div')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//h5[contains(text(),"Chapters")]/following-sibling::div/a'))

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//img[contains(@class,"lazy")]/@data-src'))

end
