function Register()

    module.Name = 'MangaLike'
    module.Language = 'Russian'
    module.Adult = false

    module.Domains.Add('mangalike.ru')

end

function GetInfo()

    info.Title = dom.SelectValue('//div[contains(@class,"__title")]')
    info.Author = dom.SelectValue('//div[contains(text(),"Автор")]/following-sibling::div')
    info.AlternativeTitle = dom.SelectValue('//div[contains(text(),"Другие названия")]/following-sibling::div')
    info.Status = dom.SelectValue('//div[contains(text(),"Выпуск")]/following-sibling::div')
    info.DateReleased = dom.SelectValue('//div[contains(text(),"Дата выпуска")]/following-sibling::div')
    info.Tags = dom.SelectValue('//div[contains(text(),"Жанры")]/following-sibling::div')
    info.Type = dom.SelectValue('//div[contains(text(),"Категории")]/following-sibling::div')
    info.Summary = dom.SelectValue('//p')

end

function GetChapters()

    local galleryId = url:regex('\\/comics\\/([^\\/]+)', 1)
    local chaptersJson = Json.New(tostring(dom):regex('"chapters":(\\[.+?\\])', 1))

    for json in chaptersJson do

        local chapter = ChapterInfo.New()

        chapter.Title = json['title']
        chapter.Volume = json['vol']
        chapter.Url = '/chapters/' .. galleryId .. '/' .. chapter.Volume .. '/' .. tostring(json['chapter'])

        chapters.Add(chapter)

    end

    chapters.Reverse()

end

function GetPages()

    local pagesJson = Json.New(tostring(dom):regex('"pages":(\\[.+?\\])', 1))    

    pages.AddRange(pagesJson.SelectValues('[*].imageSrc'))

end
