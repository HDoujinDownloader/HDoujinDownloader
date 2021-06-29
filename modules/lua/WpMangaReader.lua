function Register()

    module.Name = 'MangaReader'

    module = Module.New()

    module.Language = 'English'

    module.Domains.Add('flamescans.org', 'Flame Scans')
    module.Domains.Add('readkomik.com', 'ReadKomik')

    RegisterModule(module)

    module = Module.New()

    module.Language = 'Turkish'

    module.Domains.Add('turktoon.com', 'TurkToon')

    RegisterModule(module)

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Summary = dom.SelectValue('//div[@itemprop="description"]')
    info.Status = dom.SelectValue('//div[@class="imptdt" and contains(text(),"Status")]/*[last()]')
    info.Type = dom.SelectValue('//div[@class="imptdt" and contains(text(),"Type")]/*[last()]')
    info.Publisher = dom.SelectValue('//div[@class="imptdt" and contains(text(),"Serialization")]/*[last()]')
    info.Author = dom.SelectValue('//div[@class="imptdt" and contains(text(),"Author")]/*[last()]')
    info.Artist = dom.SelectValue('//div[@class="imptdt" and contains(text(),"Artist")]/*[last()]')

end

function GetChapters()

    for chapterNode in dom.SelectElements('//div[@id="chapterlist"]//div[contains(@class,"eph-num")]/a') do

        local chapterUrl = chapterNode.SelectValue('@href')
        local chapterTitle = chapterNode.SelectValue('span[contains(@class, "chapternum")]')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    local pagesArray = tostring(dom):regex('"images":(\\[[^\\]]+\\])', 1)
    local pagesJson = Json.New(pagesArray)

    pages.AddRange(pagesJson.SelectValues('[*]'))

    pages.Referer = ''

end
