function Register()

    module.Name = 'MangaReader'

    module = Module.New()

    module.Language = 'English'

    module.Domains.Add('acescans.xyz', 'ACE SCANS')
    module.Domains.Add('alpha-scans.org', 'Alpha Scans')
    module.Domains.Add('edoujin.net', 'edoujin')
    module.Domains.Add('flamescans.org', 'Flame Scans')
    module.Domains.Add('manhuascan.us', 'Manhuascan.us')
    module.Domains.Add('readkomik.com', 'ReadKomik')
    module.Domains.Add('realmscans.com', 'Realm Scans')
    module.Domains.Add('xcalibrscans.com', 'xCaliBR Scans')

    RegisterModule(module)

    module = Module.New()

    module.Language = 'Indonesian'

    module.Domains.Add('kiryuu.id', 'Kiryuu')

    RegisterModule(module)

    module = Module.New()

    module.Language = 'Japanese'

    module.Domains.Add('rawkuma.com', 'Rawkuma')

    RegisterModule(module)

    module = Module.New()

    module.Language = 'Spanish'

    module.Domains.Add('miauscan.com', 'miauscan.com')

    RegisterModule(module)

    module = Module.New()

    module.Language = 'Turkish'

    module.Domains.Add('108read.com', '108Read')
    module.Domains.Add('turktoon.com', 'TurkToon')

    RegisterModule(module)

    module = Module.New()

    module.Language = 'Thai'

    module.Domains.Add('108read.com', '108Read')

    RegisterModule(module)

end

function GetInfo()

    info.Title = CleanTitle(dom.SelectValue('//h1'))
    info.Summary = dom.SelectValue('//div[@itemprop="description"]')
    info.Status = dom.SelectValue('//div[@class="imptdt" and contains(text(),"Status")]/*[last()]')
    info.Type = dom.SelectValue('//div[@class="imptdt" and (contains(text(),"Type") or contains(text(),"ประเภทการ์ตูน"))]/*[last()]')
    info.Publisher = dom.SelectValue('//div[@class="imptdt" and contains(text(),"Serialization")]/*[last()]')
    info.Author = dom.SelectValue('//div[@class="imptdt" and contains(text(),"Author")]/*[last()]')
    info.Artist = dom.SelectValue('//div[@class="imptdt" and contains(text(),"Artist")]/*[last()]')
    info.Tags = dom.SelectValues('//div[contains(@class,"seriestugenre")]/a')

    -- Some sites have their metadata in a grid instead (e.g. kiryuu.id).

    if(isempty(info.Status)) then
        info.Status = dom.SelectValue('//td[contains(text(),"Status")]/following-sibling::td')
    end

    if(isempty(info.Type)) then
        info.Type = dom.SelectValue('//td[contains(text(),"Type")]/following-sibling::td')
    end

    if(isempty(info.Author)) then
        info.Author = dom.SelectValue('//td[contains(text(),"Author")]/following-sibling::td')
    end

    if(isempty(info.Author)) then -- 108read.com
        info.Author = dom.SelectValue('//b[contains(text(),"ผู้แต่ง")]/following-sibling::span')
    end

    if(isempty(info.Author)) then -- xcalibrscans.com
        info.Author = dom.SelectValue('//b[contains(text(),"Author")]/following-sibling::span')
    end

    if(isempty(info.Artist)) then
        info.Artist = dom.SelectValue('//td[contains(text(),"Author")]/following-sibling::td')
    end

    if(isempty(info.DateReleased)) then
        info.DateReleased = dom.SelectValue('//td[contains(text(),"Released")]/following-sibling::td')
    end

    if(isempty(info.Magazine)) then
        info.Magazine = dom.SelectValue('//td[contains(text(),"Serialization")]/following-sibling::td')
    end

    if(isempty(info.Tags)) then -- 108read.com
        info.Tags = dom.SelectValues('//span[contains(@class,"mgen")]//a')
    end

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

    if(not isempty(pagesArray)) then
        
        local pagesJson = Json.New(pagesArray)
        
        pages.AddRange(pagesJson.SelectValues('[*]'))

    else

        if(isempty(pages)) then

            -- manhuascan.us just has the image URLs directly in the HTML.
    
            pages.AddRange(dom.SelectValues('//div[@id="readerarea"]//img/@src'))
    
        end

    end

    pages.Referer = ''

end

function CleanTitle(title)

    return RegexReplace(title, '(?i)Bahasa Indonesia$', '')

end
