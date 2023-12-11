function Register()

    module.Name = 'CrotPedia'
    module.Language = 'indonesian'
    module.Adult = true

    module.Domains.Add('38.242.194.12')
    module.Domains.Add('158.220.106.212')
    module.Domains.Add('crotpedia.net')

    module = Module.New()

    module.Language = 'Thai'

    module.Domains.Add('germa-66.com', 'Germa-66')
    module.Domains.Add('skoiiz-manga.com', 'skoiiz-manga')

end

function GetInfo()

    info.Title = dom.SelectValue('//div[contains(@class,"series-title")]/h2')
    info.OriginalTitle = dom.SelectValue('//div[contains(@class,"series-title")]/span')
    info.Tags = dom.SelectValues('//div[contains(@class,"series-genres")]//a')
    info.Description = dom.SelectValue('//div[contains(@class,"series-synops")]')
    info.Type = dom.SelectValue('//div[contains(@class,"series-info")]/span[contains(@class,"type")]')
    info.Status = dom.SelectValue('//div[contains(@class,"series-info")]/span[contains(@class,"status")]')
    info.AlternativeTitle = dom.SelectValue('//ul[contains(@class,"series-infolist")]//b[contains(text(),"Alternative")]//following-sibling::span')
    info.Author = dom.SelectValue('//ul[contains(@class,"series-infolist")]//b[contains(text(),"Author")]//following-sibling::span')
    info.DateReleased = dom.SelectValue('//ul[contains(@class,"series-infolist")]//b[contains(text(),"Published")]//following-sibling::span')

end

function GetChapters()

    for chapterNode in dom.SelectElements('//ul[contains(@class,"chapterlist")]//div[contains(@class,"flexch-infoz")]//a') do
        
        local chapterUrl = chapterNode.SelectValue('./@href')
        local chapterTitle = chapterNode.SelectValue('./span/text()[1]')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"reader-area")]//img/@src'))

end
