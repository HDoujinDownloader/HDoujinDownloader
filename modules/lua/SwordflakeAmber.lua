-- This a design by Swordflake named "Amber".
-- https://swordflake.com/#amber

function Register()

    module.Name = 'Swordflake (Amber)'

    module = Module.New()

    module.Language = 'Spanish'

    module.Domains.Add('es.ikigaiweb.lat', 'Ikigai Mangas')
    module.Domains.Add('ikigaimangas.com', 'Ikigai Mangas')
    module.Domains.Add('visorikigai.net', 'Ikigai Mangas')

    -- We need the 'data-saving' so we can access the images (this value loads all images).

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
            print(chapterUrl)
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

    -- Images are now loaded with qwik/json.

    if(isempty(pages)) then

        local jsonStr = dom.SelectValue('//script[contains(@type,"qwik/json") and contains(text(),"page.identifier")]/text()')
        local fileNames = jsonStr:regexmany('"(\\d+\\.webp)".', 1)
        local imageServer = '//media.ikigaimangas.cloud/series/'
        local imagesPath = imageServer .. jsonStr:regex("page\\.identifier\\s*\\=\\s*'([^']+)'", 1):split('-'):join('/')

        for fileName in fileNames do
            pages.Add(imagesPath .. '/' .. fileName)
        end
        
    end

end
