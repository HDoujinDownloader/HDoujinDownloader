function Register()

    module.Name = 'Maid'

    module = Module.New()

    module.Language = 'Indonesian'

    module.Domains.Add('maid.my.id')
    module.Domains.Add('www.maid.my.id')

    RegisterModule(module)

    module = Module.New()

    module.Language = 'Thai'

    module.Domains.Add('romance-manga.com', 'Romance-manga')

    RegisterModule(module)

end

function GetInfo()

    info.Title = dom.SelectValue('//h2')
    info.OriginalTitle = dom.SelectValue('//h2/following-sibling::span')
    info.Tags = dom.SelectValues('//div[contains(@class,"series-genres")]/a')
    info.Summary = dom.SelectValue('//div[contains(@class,"series-synops")]')
    info.DateReleased = dom.SelectValue('//span[contains(@class,"published")]')

    for author in dom.SelectValue('//span[contains(@class,"author")]'):split(',') do

        local authorName = author:before('(')
        local authorRole = author:between('(', ')'):lower()

        if(authorRole == 'story') then
            info.Author = info.Author .. authorName .. ','
        elseif(authorRole == 'art') then
            info.Artist = info.Artist .. authorName .. ','
        end

    end

end

function GetChapters()

    for chapterNode in dom.SelectElements('//ul[contains(@class,"chapterlist")]//a[@title]') do

        local chapterUrl = chapterNode.SelectValue('@href')
        local chapterTitle = chapterNode.SelectValue('span[1]')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"reader-area")]//img/@src'))

end
