require "Madara"

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

function GetChapters()

    -- We need to make a POST request to get the chapters list.

    http.Headers['x-requested-with'] = 'XMLHttpRequest'

    local endpoint

    if(string.sub(url, -1) == '/') then

        endpoint = url..'ajax/chapters/'

    elseif(string.sub(url, -1) ~= '/') then

        endpoint = url..'/ajax/chapters/'

    else 

        error('Invalid POST XMLHttpRequest URL : '..url..' to get Madara chapters list')

    end

    local HTMLContentRequestBody = http.Post(endpoint)

    local dom = Dom.New(HTMLContentRequestBody)

    chapters.AddRange(dom.SelectElements('//li[contains(@class,"wp-manga-chapter")]/a'))
        
    chapters.Reverse()

end