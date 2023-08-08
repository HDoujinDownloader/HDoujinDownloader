-- This site uses the same theme as OlympusScans, but doesn't use the same API.

function Register()

    module.Name = 'Ravenmanga'
    module.Language = 'es'

    module.Domains.Add('ravenmanga.xyz')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Summary = dom.SelectValue('//section[contains(@id,"section-sinopsis")]//p')
    info.Tags = dom.SelectValues('//div[contains(text(), "Géneros:")]/following-sibling::div//a')

end

function GetChapters()

    for chapterNode in dom.SelectElements('//section[contains(@id,"section-list-cap")]//a') do

        local chapterInfo = ChapterInfo.New()

        chapterInfo.Url = chapterNode.SelectValue('./@href')
        chapterInfo.Title = chapterNode.SelectValue('.//div[contains(@id,"name")]')
        chapterInfo.Scanlator = chapterNode.SelectValue('.//div[contains(@id,"name")]/following-sibling::div')

        chapters.Add(chapterInfo)

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//main//img/@src'))

end
