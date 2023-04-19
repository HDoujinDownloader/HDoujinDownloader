-- A Madara variant similar to Madara (Ajax), except the API endpoint is different ("/ajax/chapters/").

require "Madara"

local MadaraGetPages = GetPages

function Register()

    module.Name = 'IsekaiScan'
    module.Language = 'English'

    module.Domains.Add('betafox.net', 'Beta Fox')
    module.Domains.Add('disasterscans.com', 'Disaster Scans')
    module.Domains.Add('en.leviatanscans.com', 'LeviatanScans')
    module.Domains.Add('es.leviatanscans.com', 'LeviatanScans')
    module.Domains.Add('isekaiscan.com')
    module.Domains.Add('leviatanscans.com', 'LeviatanScans')
    module.Domains.Add('lhtranslation.net', 'LHTranslation')
    module.Domains.Add('mangasushi.net', 'Mangasushi')
    module.Domains.Add('mangasushi.org', 'Mangasushi')
    module.Domains.Add('manhuamanhwa.com', 'MANHUA & MANHWA')
    module.Domains.Add('manhwahentai.me', 'ManhwaHentai.me')
    module.Domains.Add('mm-scans.org', 'Mmscans')
    module.Domains.Add('paragonscans.com', 'Paragonscans')
    module.Domains.Add('toongod.com', 'ToonGod')
    module.Domains.Add('www.betafox.net', 'Beta Fox')

    RegisterModule(module)

    module = Module.New()
    module.Language = 'Spanish'

    module.Domains.Add('selevertranslation.com', 'Selever Translation')

    RegisterModule(module)
    
end

function GetPages()

    MadaraGetPages()

    for page in pages do

        if(page.Url:contains('.wp.com/')) then

            -- Remove the redirect from Imgur images, and blank the referer so Imgur lets us access the image directly.

            page.Url = RegexReplace(page.Url, '\\/\\/[^.]+\\.wp\\.com\\/(.+?)\\?ssl=1', '//$1')
            page.Referer = ''

        end

    end

end

function GetChapters()

    local chapterListNodeCount = dom.SelectElements('//div[@id="manga-chapters-holder"]').Count()

    if(chapterListNodeCount > 0) then

        local endpoint = url:trim('/') .. '/ajax/chapters/' 

        http.Headers['x-requested-with'] = 'XMLHttpRequest'

        dom = Dom.New(http.Post(endpoint, ' '))

        local chapterNodes = dom.SelectElements('//li[contains(@class,"wp-manga-chapter") or contains(@class,"chapter-li")]/a')

        for chapterNode in chapterNodes do

            local chapterUrl = chapterNode.SelectValue('./@href')
            local chapterTitle = chapterNode.SelectValue('./text()[1]')

            if(isempty(chapterTitle)) then -- mm-scans.org
                chapterTitle = chapterNode.SelectValue('.//p')
            end

            chapters.Add(chapterUrl, chapterTitle)

        end

        chapters.Reverse()

    end

end
