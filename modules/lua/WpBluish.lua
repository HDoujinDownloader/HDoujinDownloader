-- "Bluish" is a WordPress theme.

function Register()

    module.Name = 'Bluish'
    module.Language = 'Turkish'

    module.Domains.Add('mavimanga.com', 'Mavi Manga')

end

function GetInfo()

    info.Title = dom.SelectValue('//span[contains(@class, "mangasc-title")]')
    info.Type = dom.SelectValue('//span[contains(@class, "mangasc-stat")]')
    info.AlternativeTitle = dom.SelectValue('//b[contains(text(), "Diğer Adları")]/following-sibling::text()')
    info.Author = dom.SelectValue('//b[contains(text(), "Mangaka")]/following-sibling::text()')
    info.DateReleased = dom.SelectValue('//b[contains(text(), "Çıkış Yılı")]/following-sibling::text()')
    info.Summary = dom.SelectValue('//b[contains(text(), "Konusu")]/following-sibling::text()')

    -- If a reader URL is added, we need to get the title a little differently.

    if(isempty(info.Title)) then
        info.Title = dom.SelectValue('//h1')
    end

end

function GetChapters()

    for chapterNode in dom.SelectElements('//div[contains(@class, "mangaep-list")]//tr') do

        local chapter = ChapterInfo.New()

        chapter.Url = chapterNode.SelectValue('td/a/@href')
        chapter.Title = chapterNode.SelectValue('td/a')
        chapter.Translator = chapterNode.SelectValue('td[2]')

        if(not isempty(chapter.Url)) then
            chapters.Add(chapter)
        end

    end

end

function GetPages()

    pages.AddRange(dom.SelectValues('//img/@data-src'))

end
