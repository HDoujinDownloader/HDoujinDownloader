-- This a design by Swordflake named "Amber".
-- https://swordflake.com/#amber

function Register()

    module.Name = 'Swordflake (Amber)'

    module = Module.New()

    module.Language = 'Spanish'

    if(API_VERSION >= 20240919) then
        module.Domains.Add('*')
    end

    module.Domains.Add('es.ikigaiweb.lat', 'Ikigai Mangas')
    module.Domains.Add('ikigaimangas.com', 'Ikigai Mangas')
    module.Domains.Add('ikigaimangas.meope.com', 'Ikigai Mangas')
    module.Domains.Add('lectorikigai.acamu.net', 'Ikigai Mangas')
    module.Domains.Add('lectorikigai.efope.com', 'Ikigai Mangas')
    module.Domains.Add('lectorikigai.erigu.com', 'Ikigai Mangas')
    module.Domains.Add('visorikigai.imsin.net', 'Ikigai Mangas')
    module.Domains.Add('visorikigai.meope.com', 'Ikigai Mangas')
    module.Domains.Add('visorikigai.net', 'Ikigai Mangas')
    module.Domains.Add('visorikigai.nipase.com', 'Ikigai Mangas')
    module.Domains.Add('visualikigai.com', 'Ikigai Mangas')

end

local function CheckGenericMatch()

    if(API_VERSION < 20240919) then
        return
    end

    if(not module.IsGeneric) then
        return
    end

    local isGenericMatch = dom.SelectNodes('//footer//span[contains(text(),"Swordflake")]').Count() > 0

    if(not isGenericMatch) then
        Fail(Error.DomainNotSupported)
    end

end

function GetInfo()

    CheckGenericMatch()

    info.Title = dom.SelectValue('//h1')
    info.Summary = dom.SelectValue('//h1/following-sibling::p')
    info.Tags = dom.SelectValues('//ul//a[contains(@href,"?generos")]')
    info.ChapterCount = dom.SelectValue('//h2[contains(text(),"Capítulos")]'):regex('\\d+')

end

function GetChapters()

    CheckGenericMatch()

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

    CheckGenericMatch()

    -- We need the 'data-saving' so we can access the images (this value loads all images).

    http.Cookies.Add(GetHost(url), 'data-saving', '0')

    dom = Dom.New(http.Get(url))

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
