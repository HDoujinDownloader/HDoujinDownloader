function Register()

    module.Name = 'Nartag'
    module.Language = 'es'

    module.Domains.Add('nartag.com')

end

function GetInfo()
    
    info.Title = dom.SelectValue('//h2')
    info.Summary = dom.SelectValue('//div[contains(@class,"manga__description")]')
    info.Tags = dom.SelectValues('//div[contains(@class,"categories__list")]//a')
    info.Status = dom.SelectValue('//div[contains(@class,"manga__status")]//span')

end

function GetChapters()

    for chapterNode in dom.SelectElements('//div[contains(@class,"chapter__item")]') do
        
        local chapterTitle = chapterNode.SelectValue('.//*[contains(@class,"chapter__title")]')
        local chapterUrl = chapterNode.SelectValue('.//a/@href')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"reader__item")]//img/@data-src'))

end
