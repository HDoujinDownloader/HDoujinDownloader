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
    info.Tags = dom.SelectValues('//label[contains(text(),"Genres")]/following-sibling::a')
    info.Type = dom.SelectValue('//label[contains(text(),"Type")]/following-sibling::div')
    info.Status = dom.SelectValue('//label[contains(text(),"Status")]/following-sibling::div')
    info.DateReleased = dom.SelectValue('//label[contains(text(),"Year")]/following-sibling::div')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//div[contains(@id,"chapters")]//a'))

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//img[contains(@loading,"lazy")]/@data-src'))

end
