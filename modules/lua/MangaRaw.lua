function Register()

    module.Name = 'MangaRaw'
    module.Language = 'English'

    module.Domains.Add('manga-raw.club')
    module.Domains.Add('mcreader.net')
    module.Domains.Add('www.manga-raw.club')
    module.Domains.Add('www.manga-raw.club')
    module.Domains.Add('www.mcreader.net')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.AlternativeTitle = dom.SelectValue('//h2[contains(@class,"alternative-title")]')
    info.Author = dom.SelectValues('//span[@itemprop="author"]')
    info.Status = dom.SelectValue('//span[contains(.,"Status")]/strong')
    info.Tags = dom.SelectValues('//strong[contains(text(),"Categories")]/following-sibling::ul//a')
    info.Summary = dom.SelectValue('//p[contains(@class,"description")]')    

end

function GetChapters()
 
    for chapterNode in dom.SelectElements('//ul[contains(@class,"chapter-list")]/li') do

        local chapterUrl = chapterNode.SelectValue('.//a/@href')
        local chapterTitle = chapterNode.SelectValue('.//*[contains(@class,"chapter-title")]')
        
        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//section[contains(@class,"page-in")]//img/@src'))

end
