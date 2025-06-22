-- This module is almost the same as (if not identical tostring) "WpMangaStream" (potential duplicate?).

require "TSReader"

local TSReaderGetPages = GetPages

function Register()
    module.Name = 'MangaReader'

    -- Enable generic support for MangaRead/MangaStream websites.

    module.Domains:Add('*')

    module = Module.New()
    module.Language = 'English'

    module.Domains:Add('acescans.xyz', 'ACE SCANS')
    module.Domains:Add('alpha-scans.org', 'Alpha Scans')
    module.Domains:Add('anigliscans.com', 'Animated Glitched Scans')
    module.Domains:Add('anigliscans.xyz', 'Animated Glitched Scans')
    module.Domains:Add('arvencomics.com', 'Arven Scans')
    module.Domains:Add('arvenscans.org', 'Arven Scans')
    module.Domains:Add('constellarscans.com', 'Constellar Scans')
    module.Domains:Add('edoujin.net', 'edoujin')
    module.Domains:Add('hentai20.io', 'Hentai20.io')
    module.Domains:Add('lunarscan.org', 'Lunar Scans')
    module.Domains:Add('mangagalaxy.me', 'Manga Galaxy')
    module.Domains:Add('manhuascan.us', 'Manhuascan.us')
    module.Domains:Add('night-scans.com', 'Night Scans')
    module.Domains:Add('night-scans.net', 'Night Scans')
    module.Domains:Add('nightscans.net', 'Night Scans')
    module.Domains:Add('nightscans.org', 'Night Scans')
    module.Domains:Add('nightsup.net', 'Night scans')
    module.Domains:Add('nocturnalscans.com', 'Nocturnal Scanlations')
    module.Domains:Add('readkomik.com', 'ReadKomik')
    module.Domains:Add('realmscans.com', 'Realm Scans')
    module.Domains:Add('realmscans.to', 'Realm Scans')
    module.Domains:Add('realmscans.xyz', 'Realm Scans')
    module.Domains:Add('reaper-scans.com', 'Reaper Scans')
    module.Domains:Add('rizzcomic.com', 'Rizz Comics')
    module.Domains:Add('rizzfables.com', 'Rizz Fables')
    module.Domains:Add('suryascans.com', 'Surya Scans')
    module.Domains:Add('xcalibrscans.com', 'xCaliBR Scans')

    RegisterModule(module)

    module = Module.New()
    module.Language = 'Arabic'

    module.Domains:Add('manjanoon.org', 'مانجا نون')

    RegisterModule(module)

    module = Module.New()
    module.Language = 'Indonesian'

    module.Domains:Add('159.223.38.69', 'sasangeyou')
    module.Domains:Add('kanzenin.info', 'kanzenin')
    module.Domains:Add('kiryuu.id', 'Kiryuu')
    module.Domains:Add('sasangeyou.xyz', 'sasangeyou')

    RegisterModule(module)

    module = Module.New()
    module.Language = 'Japanese'

    module.Domains:Add('rawkuma.com', 'Rawkuma')

    RegisterModule(module)

    module = Module:New()
    module.Language = 'Portuguese'

    module.Domains:Add('sssscanlator.com.br', 'sssscanlator')

    RegisterModule(module)

    module = Module.New()
    module.Language = 'Spanish'

    module.Domains:Add('lectorhentai.com', 'Lector Hentai')
    module.Domains:Add('legionscans.com', 'LEGION SCAN')
    module.Domains:Add('miauscan.com', 'miauscan.com')
    module.Domains:Add('miauscans.com', 'miauscans.com')
    module.Domains:Add('ragnascan.com', 'Ragna Scan')
    module.Domains:Add('raikiscan.com', 'Raiki Scan')
    module.Domains:Add('shadowmangas.com', 'ShadowMangas')
    module.Domains:Add('shotasekai.club', 'Shota Sekai')
    module.Domains:Add('tecnoscann.com', 'Tecno scan')
    module.Domains:Add('tresdaos.com', 'Tres daos')

    RegisterModule(module)

    module = Module.New()
    module.Language = 'Turkish'

    module.Domains:Add('108read.com', '108Read')
    module.Domains:Add('turktoon.com', 'TurkToon')

    RegisterModule(module)

    module = Module.New()
    module.Language = 'Thai'

    module.Domains:Add('108read.com', '108Read')
    module.Domains:Add('doujin-y.com', 'Doujin-Y')
    module.Domains:Add('eye-manga.com', 'EYE-Manga')
    module.Domains:Add('flash-manga.com', 'Flash-Manga')
    module.Domains:Add('god-doujin.com', 'God-Doujin')
    module.Domains:Add('hippomanga.com', 'Hippomanga')
    module.Domains:Add('inu-manga.com', 'Inu Manga')
    module.Domains:Add('joji-manga.com', 'Joji-Manga')
    module.Domains:Add('makimaaaaa.com', 'makimaaaaa')
    module.Domains:Add('manga-moons.net', 'Manga-Moon')
    module.Domains:Add('manga168.net', 'Manga168')
    module.Domains:Add('manga1688.com', 'Manga168')
    module.Domains:Add('mangalami.com', 'Lami-Manga')
    module.Domains:Add('one-manga.com', 'One-manga')
    module.Domains:Add('ped-manga.com', 'Ped-Manga.com')
    module.Domains:Add('popsmanga.com', 'PopsManga')
    module.Domains:Add('reapertrans.com', 'Reapertrans.com')
    module.Domains:Add('rom-manga.com', 'ROM-Manga')
    module.Domains:Add('slow-manga.com', 'SLOW-MANGA')
    module.Domains:Add('spy-manga.com', 'Spy-manga')
    module.Domains:Add('up-manga.com', 'Up-Manga')
    module.Domains:Add('webtoonmanga.com', 'webtoonmanga')
    module.Domains:Add('www.doujin-y.com', 'Doujin-Y')
    module.Domains:Add('www.eye-manga.com', 'EYE-Manga')
    module.Domains:Add('www.flash-manga.com', 'Flash-Manga')
    module.Domains:Add('www.inu-manga.com', 'Inu Manga')
    module.Domains:Add('www.rom-manga.com', 'ROM-Manga')
    module.Domains:Add('www.slow-manga.com', 'SLOW-MANGA')
    module.Domains:Add('www.up-manga.com', 'Up-Manga')
    module.Domains:Add('xenon-manga.com', 'xenon-manga.com')

    RegisterModule(module)
end

local function CheckGenericMatch()
    if API_VERSION < 20240919 then
        return
    end

    if not module.IsGeneric then
        return
    end

    local isGenericMatch = dom.SelectNodes('//script[contains(@src,"/themes/mangastream/")]|//script[contains(@src,"/themes/mangareader/")]').Count() > 0

    -- If we can't detect the theme directly, look for "eph-num" chapter nodes.

    if not isGenericMatch then
        isGenericMatch = dom.SelectNodes('//div[@id="chapterlist"]//div[contains(@class,"eph-num")]/a').Count() > 0
    end

    -- Attempt to handle individual chapters that use "ts_reader".

    if not isGenericMatch then
        isGenericMatch = dom.SelectNodes('//script[contains(text(), "ts_reader.run")]').Count() > 0
    end

    if not isGenericMatch then
        Fail(Error.DomainNotSupported)
    end
end

local function CleanTitle(title)
    return RegexReplace(title, '(?i)Bahasa Indonesia$', '')
end

local function GetPageCount()
    return dom.SelectElements('//div[@id="chapterlist"]//div[contains(@class,"bsx")]').Count()
end

local function GetReaderUrl()
    return dom.SelectValue('//div[contains(@class,"releases")]//a/@href')
end

function GetInfo()
    CheckGenericMatch()

    info.Title = CleanTitle(dom.SelectValue('//h1[contains(@class,"entry-title")]|h1'))
    info.AlternativeTitle = dom.SelectValue('//span[contains(@class,"alternative")]')
    info.Summary = dom.SelectValue('//div[@itemprop="description"]')
    info.Status = dom.SelectValue('//div[@class="imptdt" and (contains(.,"Status") or contains(.,"สถานะ") or contains(.,"Estado"))]/*[last()]')
    info.Type = dom.SelectValue('//div[@class="imptdt" and (contains(.,"Type") or contains(.,"ประเภทการ์ตูน") or contains(.,"พิมพ์") or contains(.,"Tipo") or contains(.,"ประเภท"))]/*[last()]')
    info.Publisher = dom.SelectValue('//div[@class="imptdt" and (contains(.,"Serialization") or contains(.,"การทำให้เป็นอนุกรม"))]/*[last()]')
    info.Author = dom.SelectValue('//div[@class="imptdt" and (contains(.,"Author") or contains(.,"ผู้เขียน") or contains(.,"Autor") or contains(.,"ผู้แต่ง"))]/*[last()]')
    info.Artist = dom.SelectValue('//div[@class="imptdt" and (contains(.,"Artist") or contains(.,"ศิลปิน") or contains(.,"ผู้วาด"))]/*[last()]')
    info.Tags = dom.SelectValues('//div[contains(@class,"seriestugenre")]/a')
    info.DateReleased = dom.SelectValue('//div[@class="imptdt" and (contains(.,"วันที่ปล่อย"))]/*[last()]')

    -- Some sites have their metadata in a grid instead (e.g. kiryuu.id).

    if isempty(info.Status) then
        info.Status = dom.SelectValue('//td[contains(text(),"Status") or contains(text(),"สถานะ")]/following-sibling::td')
    end

    if isempty(info.Type) then
        info.Type = dom.SelectValue('//td[contains(text(),"Type") or contains(text(),"ประเภท")]/following-sibling::td')
    end

    if isempty(info.Author) then
        info.Author = dom.SelectValue('//td[contains(text(),"Author") or contains(text(),"ผู้เขียน")]/following-sibling::td')
    end

    if isempty(info.Author) then -- 108read.com
        info.Author = dom.SelectValue('//b[contains(text(),"ผู้แต่ง")]/following-sibling::span')
    end

    if isempty(info.Author) then -- xcalibrscans.com
        info.Author = dom.SelectValue('//b[contains(text(),"Author")]/following-sibling::span')
    end

    if isempty(info.Artist) then
        info.Artist = dom.SelectValue('//td[contains(text(),"Author")]/following-sibling::td')
    end

    if isempty(info.Artist) then -- nocturnalscans.com
        info.Artist = dom.SelectValue('//b[contains(text(),"Artist")]/following-sibling::span')
    end

    if isempty(info.Artist) then -- manjanoon.org
        info.Artist = dom.SelectValue('//div[contains(.,"الرسام")]/span')
    end

    if isempty(info.Artist) then
        info.DateReleased = dom.SelectValue('//td[contains(text(),"Artist") or contains(text(),"ผู้แต่ง")]/following-sibling::td')
    end

    if isempty(info.DateReleased) then
        info.DateReleased = dom.SelectValue('//td[contains(text(),"Released") or contains(text(),"ปีที่ปล่อย")]/following-sibling::td')
    end

    if isempty(info.DateReleased) then -- nightscans.org
        info.DateReleased = dom.SelectValue('//div[contains(text(),"Released")]//following-sibling::i')
    end

    if isempty(info.DateReleased) then -- nocturnalscans.com
        info.DateReleased = dom.SelectValue('//b[contains(text(),"Released")]/following-sibling::span')
    end

    if isempty(info.Magazine) then
        info.Magazine = dom.SelectValue('//td[contains(text(),"Serialization")]/following-sibling::td')
    end

    if isempty(info.Publisher) then -- nocturnalscans.com
        info.Publisher = dom.SelectValue('//b[contains(text(),"Serialization")]/following-sibling::span')
    end

    if isempty(info.Summary) then -- rizzcomic.com
        info.Summary = dom.SelectValue('//div[contains(@id,"description-container")]')
    end

    if module.GetName(url):endsWith('Scans') or module.GetName(url):endsWith('Scanlations') then
        info.Scanlator = module.GetName(url)
    end

    if isempty(info.Tags) then -- 108read.com
        info.Tags = dom.SelectValues('//span[contains(@class,"mgen")]//a')
    end

    if not isempty(info.Author) and info.Author:trim() == '-' then
        info.Author = ''
    end

    -- Get the page count if we're on a site that doesn't use chapters (lectorhentai.com).
    local pageCount = GetPageCount()

    if pageCount > 0 then
        info.PageCount = pageCount
    end
end

function GetChapters()
    CheckGenericMatch()

    local chapterNodes = dom.SelectElements('//div[@id="chapterlist"]//div[contains(@class,"eph-num")]/a')

    for chapterNode in chapterNodes do
        local chapterUrl = chapterNode.SelectValue('@href')
        local chapterTitle = chapterNode.SelectValue('.//span[contains(@class, "chapternum")]')

        chapters.Add(chapterUrl, chapterTitle)
    end

    chapters.Reverse()
end

function GetPages()
    CheckGenericMatch()

    -- Open the reader URL if we're currently on the summary page (lectorhentai.com).
    local readerUrl = GetReaderUrl()

    if not isempty(readerUrl) then
        url = readerUrl
        dom = Dom.New(http.Get(url))
    end

    local pagesArray = tostring(dom):regex('"images"\\s*:\\s*(\\[[^\\]]+\\])', 1)

    if not isempty(pagesArray) then
        local pagesJson = Json.New(pagesArray)

        pages.AddRange(pagesJson.SelectValues('[*]'))
    end

    -- ManhuaScan (manhuascan.us) just has the image URLs directly in the HTML.
    if isempty(pages) then
        pages.AddRange(dom.SelectValues('//div[@id="readerarea"]//img/@src'))
    end

    -- Doujin-Y (doujin-y.com) uses "ts_reader".
    if isempty(pages) then
        TSReaderGetPages()
    end

    -- Some sites use external image hosts from which downloads will fail if we set a referer.
    -- However, some other sites require a referer in order to download.
    local refererRequiredDomains = {
        "manga1688.",
        "realmscans.",
        "rizzcomic.",
    }
    local refererRequired = false

    for _, domain in ipairs(refererRequiredDomains) do
        if module.Domain:startswith(domain) then
            refererRequired = true
            break
        end
    end

    pages.Referer = refererRequired and GetRoot(url) or ""
end
