require "Madara"

function Register()

    module.Name = 'YugenMangas'
    module.Language = 'es'

    module.Domains.Add('yugenmangas.com')

end

function GetChapters()

    for chapterNode in dom.SelectElements('//div[contains(@class,"chapter-link")]') do

        local chapterUrl = chapterNode.SelectValue('./a/@href')
        local chapterTitle = chapterNode.SelectValue('.//p')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end
