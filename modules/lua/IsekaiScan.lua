-- A Madara variant similar to Madara (Ajax), except the API endpoint is different ("/ajax/chapters/").

require "Madara"

local BaseGetInfo = GetInfo
local BaseGetPages = GetPages

function Register()

    module.Name = 'IsekaiScan'
    module.Language = 'English'

    module.Domains.Add('betafox.net', 'Beta Fox')
    module.Domains.Add('dark-scan.com', 'Dark scan')
    module.Domains.Add('disasterscans.com', 'Disaster Scans')
    module.Domains.Add('hunlight.com', 'Hunlight Scans')
    module.Domains.Add('isekaiscan.com')
    module.Domains.Add('lhtranslation.net', 'LHTranslation')
    module.Domains.Add('mangasushi.net', 'Mangasushi')
    module.Domains.Add('mangasushi.org', 'Mangasushi')
    module.Domains.Add('manhuamanhwa.com', 'MANHUA & MANHWA')
    module.Domains.Add('mm-scans.org', 'Mmscans')
    module.Domains.Add('novelcrow.com', 'NovelCrow')
    module.Domains.Add('rackusreads.com', 'New Rackus!')
    module.Domains.Add('reset-scans.us', 'RESET SCANS')
    module.Domains.Add('reset-scans.xyz', 'RESET SCANS')
    module.Domains.Add('resetscan.com', 'RESET SCANS')
    module.Domains.Add('tcbscans-manga.com', 'TCB Scans')
    module.Domains.Add('tcbscans.net', 'TCB Scans')
    module.Domains.Add('theblank.net', 'The Blank')
    module.Domains.Add('www.betafox.net', 'Beta Fox')
    module.Domains.Add('www.tcbscans.net', 'TCB Scans')

    module = Module.New()

    module.Language = 'French'

    module.Domains.Add('toonfr.com', 'Toonfr')
    module.Domains.Add('x-manga.net', 'X-MANGA')

    module = Module.New()

    module.Language = 'Portuguese'

    module.Domains.Add('noindexscan.com', 'No Index Scan')

    module = Module.New()

    module.Language = 'Spanish'

    module.Domains.Add('bokugents.com', 'Bokugen Translations')
    module.Domains.Add('dominiomarcial.com', 'Mantraz Scan')
    module.Domains.Add('hadesnofansub.com', 'HADES NO FANSUB')
    module.Domains.Add('housemangas.com', 'HouseMangas')
    module.Domains.Add('lectorespanol.com', 'Lector español')
    module.Domains.Add('lectormh.com', 'MH Scans')
    module.Domains.Add('manhuaespanol.com', 'Manhuas español')
    module.Domains.Add('mantraz-scan.com', 'Manhuas español')
    module.Domains.Add('mantrazscan.com', 'Manhuas español')
    module.Domains.Add('mg.mundodrama.site', 'Inmortal scan')
    module.Domains.Add('mh.twobluescans.com', 'MH Scans')
    module.Domains.Add('mhscans.com', 'MHScans')
    module.Domains.Add('panconcola.com', 'Mantraz Scan')
    module.Domains.Add('ragnarokscanlation.com', 'Ragnarok Scanlation')
    module.Domains.Add('selevertranslation.com', 'Selever Translation')
    module.Domains.Add('taurusfansub.com', 'Taurus Fansub')
    module.Domains.Add('visorscamber-scans.com', 'visorscamber')
    module.Domains.Add('visortecno.com', 'Visor Tecno')
    
    module = Module.New()
    
    module.Language = 'Thai'

    module.Domains.Add('fcmanga.com', 'Fcmanga')

end

local function GetChaptersFromNode(node, volumeNumber)

    local chapterNodes = node.SelectElements('.//li[contains(@class,"wp-manga-chapter") or contains(@class,"chapter-li")]/a')

    for chapterNode in chapterNodes do

        local chapterInfo = ChapterInfo.New()

        chapterInfo.Url = chapterNode.SelectValue('./@href')
        chapterInfo.Title = chapterNode.SelectValue('./text()[1]')

        if(isempty(chapterInfo.Title)) then -- mm-scans.org
            chapterInfo.Title = chapterNode.SelectValue('.//p')
        end

        if(isempty(chapterInfo.Title)) then -- reset-scans.us
            chapterInfo.Title = chapterNode.SelectValue('.//following-sibling::div/a/text()')
        end

        if(volumeNumber ~= nil) then
            
            chapterInfo.Volume = volumeNumber

            chapterInfo.Title = 'Volume ' .. volumeNumber .. ' ' .. chapterInfo.Title

        end

        -- Some sites have download links that we need to ignore (lhtranslation.net).

        if(chapterInfo.Url ~= "#") then
            chapters.Add(chapterInfo)
        end

    end

end

function GetInfo()

    BaseGetInfo()

    -- rackusreads.com uses an anti-adblocker that messes with the title.

    if(info.Title:contains('DETECTED ADBLOCKER')) then
        info.Title = dom.SelectValue('//div[contains(@class,"post-title")]//h1')
    end

end

function GetPages()

    BaseGetPages()

    for page in pages do

        if(page.Url:contains('.wp.com/')) then

            -- Remove the redirect from Imgur images, and blank the referer so Imgur lets us access the image directly.

            page.Url = RegexReplace(page.Url, '\\/\\/[^.]+\\.wp\\.com\\/(.+?)\\?ssl=1', '//$1')
            page.Referer = ''

        end

    end

end

function GetChapters()

    local chapterListNodeCount = dom.SelectElements('//div[@id="manga-chapters-holder" or contains(@class, "chapter-content")]').Count()

    if(chapterListNodeCount > 0) then

        local endpoint = url:trim('/') .. '/ajax/chapters/'

        http.Headers['x-requested-with'] = 'XMLHttpRequest'

        dom = Dom.New(http.Post(endpoint, ' '))

        -- Chapters may be split up into separate volumes.

        local volumeNodes = dom.SelectElements('//li[a[contains(text(),"Volume")]]')

        for volumeNode in volumeNodes do
           
            local volumeNumber = volumeNode.SelectValue('./a'):regex('\\d+')

            GetChaptersFromNode(volumeNode, volumeNumber)

        end

        if(volumeNodes.Count() <= 0) then

            GetChaptersFromNode(dom)

        end

        chapters.Reverse()

    end

end
