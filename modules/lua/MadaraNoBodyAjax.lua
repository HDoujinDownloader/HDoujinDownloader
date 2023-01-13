-- Note: This module may be a duplicate of IsekaiScan.lua.
-- Consider moving the sites contained here into that module instead.

require "Madara"

local BaseGetPages = GetPages

function Register()

    module.Name = 'Madara (No Body Ajax)'
    module.Language = 'English'

    module.Domains.Add('hentai20.com', 'Hentai20')
    module.Domains.Add('hentaidexy.com', 'hentaidexy')
    module.Domains.Add('hiperdex.com', 'Hiperdex')
    module.Domains.Add('isekaiscanmanga.com', 'Isekaiscan Manga')
    module.Domains.Add('mangarockteam.com', 'Manga Rock Team')
    module.Domains.Add('mangasushi.net', 'Mangasushi')
    module.Domains.Add('mangasushi.org', 'Mangasushi')
    module.Domains.Add('manhuaga.com', 'Manhuaga Scans')
    module.Domains.Add('manhuaplus.com', 'ManhuaPLus')
    module.Domains.Add('manhuaus.com', 'Manhuaus.com')
    module.Domains.Add('immortalupdates.com', 'Immortal Updates')
    module.Domains.Add('zinmanga.com', 'Zinmanga')

end

function GetPages()

    BaseGetPages()

    for page in pages do

        -- Websites using WordPress.com for image hosting (e.g. manhuaplus.com) need to have a referer set in order to access the image directly.

        if(page.Url:contains('.wordpress.com/')) then
            page.Referer = url
        end

    end

end

function GetChapters()

    -- We need to make a POST request to get the chapter list.
    -- We don't actually need to send any POST data, so an empty body is sent.

    http.Headers['accept'] = '*/*'
    http.Headers['x-requested-with'] = 'XMLHttpRequest'

    local endpoint = 'ajax/chapters/'
    local dom = dom.New(http.Post(endpoint, ' '))

    chapters.AddRange(dom.SelectElements('//li[contains(@class,"wp-manga-chapter")]/a'))
        
    chapters.Reverse()

end
