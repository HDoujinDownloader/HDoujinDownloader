require "MyMangaReaderCms"

function Register()

    module.Name = 'Mangas.in'
    module.Language = 'Spanish'
    module.Adult = false

    module.Domains.Add('mangas.in')

end

function GetChapters()

    for chapterNode in dom.SelectElements('//ul[contains(@class,"chapters")]//h5') do

        local chapterTitle = chapterNode.SelectValue('a/following-sibling::text()')
        local chapterSubtitle = chapterNode.SelectValue('daka')
        local chapterUrl = chapterNode.SelectValue('daka/a/@href')

        chapters.Add(chapterUrl, CleanTitle(chapterTitle .. chapterSubtitle))

    end

    chapters.Reverse()

end
