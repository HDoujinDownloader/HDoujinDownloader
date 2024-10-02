function Register()

    module.Name = 'Hentai18'
    module.Language = 'en'
    module.Adult = true

    module.Domains.Add('hentai18.net')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.AlternativeTitle = dom.SelectValue('//h2[contains(@class,"alternative")]')
    info.Artist = dom.SelectValues('//span[contains(text(),"Artists")]/following-sibling::span//a')
    info.Tags = dom.SelectValues('//span[contains(text(),"Tags")]/following-sibling::span//a')
    info.Type = dom.SelectValues('//span[contains(text(),"Category")]/following-sibling::span//a')
    info.Status = dom.SelectValues('//span[contains(text(),"Status")]/following-sibling::span')

end

function GetChapters()
    chapters.AddRange(dom.SelectElements('//ul[contains(@id,"chapter-list")]//a'))
end

function GetPages()
    pages.AddRange(dom.SelectValues('//div[contains(@class,"chapter-content")]//img/@src'))
end
