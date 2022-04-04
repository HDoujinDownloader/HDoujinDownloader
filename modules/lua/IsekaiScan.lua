-- A Madara variant similar to Madara (Ajax), except the API endpoint is different ("/ajax/chapters/").

require "Madara"

local MadaraGetPages = GetPages

function Register()

    module.Name = 'IsekaiScan'
    module.Language = 'English'

    module.Domains.Add('betafox.net', 'Beta Fox')
    module.Domains.Add('disasterscans.com', 'Disaster Scans')
    module.Domains.Add('isekaiscan.com')
    module.Domains.Add('manhwahentai.me', 'ManhwaHentai.me')
    module.Domains.Add('toongod.com', 'ToonGod')
    module.Domains.Add('www.betafox.net', 'Beta Fox')
    

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

        chapters.AddRange(dom.SelectElements('//li[contains(@class,"wp-manga-chapter")]/a'))
    
        chapters.Reverse()

    end

end
