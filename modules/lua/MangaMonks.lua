function Register()

    module.Name = 'Manga Monks'
    module.Language = 'en'

    module.Domains.Add('mangamonks.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h3[contains(@class,"info-title")]')
    info.Status = dom.SelectValue('//span[contains(@data-bs-original-title,"Manga Status")]')
    info.AlternativeTitle = dom.SelectValue('//span[contains(@data-bs-original-title,"Alternative Title(s)")]'):split(';')
    info.Tags = dom.SelectValues('//div[contains(@class,"manga-tags")]//a')
    info.Summary = dom.SelectValue('//div[contains(@class,"info-desc")]')

end

function GetChapters()

    for chapterNode in dom.SelectElements('//div[contains(@class,"chapter-list")]//a[not(@id="chapter-sort")]') do

        local chapterUrl = chapterNode.SelectValue('./@href')
        local chapterTitle = chapterNode.SelectValue('./span[contains(@class,"chapter-number")]')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()
    pages.AddRange(dom.SelectValues('//div[contains(@id,"image-")]/img/@src'))
end
