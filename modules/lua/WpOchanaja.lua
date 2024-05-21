function Register()

    module.Name = 'Ochanaja'
    module.Language = 'Thai'

    module.Domains.Add('manga00.com', 'Manga00')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1[contains(@class,"entry-title")]')
    info.Status = dom.SelectValue('//b[contains(text(),"สถานะ")]/following-sibling::text()')
    info.Type = dom.SelectValue('//b[contains(text(),"ประเภท")]/following-sibling::text()')
    info.Author = dom.SelectValue('//b[contains(text(),"ผู้เขียน")]/following-sibling::a')
    info.DateReleased = dom.SelectValue('//b[contains(text(),"ปี")]/following-sibling::a')
    info.Summary = dom.SelectValue('//div[@itemprop="description"]')
    info.Tags = dom.SelectValues('//div[contains(@class,"genre-info")]/a')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//span[contains(@class,"lchx")]/a'))

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//img[@id="imagech"]/@src'))

end
