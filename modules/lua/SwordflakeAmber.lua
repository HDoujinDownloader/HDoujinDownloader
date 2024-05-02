-- This a design by Swordflake named "Amber". 
-- https://swordflake.com/#amber

function Register()

    module.Name = 'Swordflake (Amber)'

    module = Module.New()

    module.Language = 'Spanish'

    module.Domains.Add('visorikigai.net', 'Ikigai Mangas')

    global.SetCookie('.' .. module.Domains.First(), "data-saving", "0")

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Summary = dom.SelectValue('//h1/following-sibling::p')
    info.Tags = dom.SelectValues('//ul//a[contains(@href,"?generos")]')
    info.ChapterCount = dom.SelectValue('//h2[contains(text(),"Capítulos")]'):regex('\\d+')

end

function GetChapters()
    
    local seenChapters = {}

    for page in Paginator.New(http, dom, '//nav[contains(@aria-label,"pagination")]//a[span[contains(@class,"arrow-right")]]/@href') do
    
        local chapterNodes = page.SelectElements('//ul[contains(@class,"grid")]//a[contains(@href,"capitulo")]')

        for i = 0, chapterNodes.Count() - 1 do

            local chapterNode = chapterNodes[i]
            local chapterUrl = chapterNode.SelectValue('./@href')
            local chapterTitle = chapterNode.SelectValue('.//h3')
            
            if(not seenChapters[chapterUrl]) then
                chapters.Add(chapterUrl, chapterTitle)
            end

            seenChapters[chapterUrl] = true

        end

    end

    chapters.Reverse()

end

function GetPages()
    pages.AddRange(dom.SelectValues('//img[contains(@alt,"Page")]/@src'))
end
