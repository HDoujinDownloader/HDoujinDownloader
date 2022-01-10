function Register()

    module.Name = 'Mangá Host'
    module.Language = 'Português'
    module.Adult = false

    module.Domains.Add('br.mangahost.com')
    module.Domains.Add('mangahosted.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.AlternativeTitle = dom.SelectValue("//h3[contains(@class,'subtitle')]")
    info.Status = dom.SelectValue("//h3[contains(@class,'subtitle')]/strong")    
    info.Tags = dom.SelectValues('//div[contains(@class,"tags")]/a[contains(@class,"tag")]')
    info.Type = dom.SelectValue('//strong[contains(.,"Tipo:")]/following-sibling::a')
    info.Author = dom.SelectValue('//strong[contains(.,"Autor:")]/following-sibling::text()')
    info.Artist = dom.SelectValue('//strong[contains(.,"Arte:")]/following-sibling::text()')
    info.DateReleased = dom.SelectValue('//strong[contains(.,"Ano:")]/following-sibling::text()')
    info.ReadingDirection = dom.SelectValue('//strong[contains(.,"Modo de Leitura:")]/following-sibling::text()')
    info.Scanlator = dom.SelectValue('//strong[contains(.,"Scan(s):")]/following-sibling::text()')
    info.Summary = dom.SelectValue('//div[contains(@class,"paragraph")]')

end

function GetChapters()

    for chapterNode in dom.SelectElements('//div[contains(@class,"card pop")]') do

        local chapterInfo = ChapterInfo.New()

        chapterInfo.Url = chapterNode.SelectValue('.//a/@href')
        chapterInfo.Title = chapterNode.SelectValue('.//div[contains(@class,"pop-title")]')
        chapterInfo.Translator = chapterNode.SelectValue('.//small/strong')

        chapters.Add(chapterInfo)

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//img[contains(@id,"img_")]/@src'))

end
