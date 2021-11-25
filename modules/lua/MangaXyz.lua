function Register()

    module.Name = 'MangaXYZ'
    module.Language = 'en'

    module.Domains.Add('mangaxyz.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.AlternativeTitle = dom.SelectValue('//h2'):split('/')
    info.Author = dom.SelectValues('//strong[contains(.,"Authors")]/following-sibling::a')    
    info.Status = dom.SelectValue('//strong[contains(.,"Status")]/following-sibling::a')    
    info.Tags = dom.SelectValues('//strong[contains(.,"Genres")]/following-sibling::a')    
    info.Summary = dom.SelectValue('//p[contains(@class,"content")]')

end

function GetChapters()

    dom = Dom.New(GetApiChapters())

    for chapterNode in dom.SelectElements('//a') do

        local chapterUrl = chapterNode.SelectValue('@href')
        local chapterTitle = chapterNode.SelectValue('.//*[contains(@class,"chapter-title")]')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    local chapImagesScript = dom.SelectValue('//script[contains(.,"chapImages")]')
    local serversScript = dom.SelectValue('//script[contains(.,"mainServer")]')

    local js = JavaScript.New()

    js.Execute(chapImagesScript)
    js.Execute(serversScript)

    local chapImages = tostring(js.GetObject('chapImages'))
    local server = tostring(js.GetObject('mainServer'))

    for image in chapImages:split(',') do

        pages.Add(server .. image)

    end

end

function GetApiUrl()

    -- https://mangaxyz.com/api/manga/

    return 'https://' .. module.Domain .. '/api/manga/'

end

function GetMangaSlug()

    return dom.SelectValue('//script[contains(.,"bookSlug")]')
        :regex('bookSlug\\s*=\\s*"(?<slug>[^"]+)', 1)

end

function GetApiChapters()

    local bookSlug = GetMangaSlug()

    return http.Get(GetApiUrl() .. bookSlug .. '/chapters?source=detail')

end
