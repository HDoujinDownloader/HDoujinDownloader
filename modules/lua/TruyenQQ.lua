function Register()

    module.Name = 'TruyenQQ'
    module.Language = 'Vietnamese'
    module.Adult = false

    module.Domains.Add('truyenqq.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Author = dom.SelectValues('//p[contains(text(),"Tác giả:")]/a')
    info.Status = dom.SelectValue('//p[contains(text(),"Tình trạng:")]'):after(':')
    info.Tags = dom.SelectValues('//div[contains(@class,"center")]//ul//a')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//div[contains(@class,"chapter-list")]//a'))

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"story-see-content")]//img/@src'))

end
