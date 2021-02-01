require "Madara"

function Register()

    module.Name = 'EarlyManga'
    module.Language = 'English'

    module.Domains.Add('aloalivn.com', 'Aloalivn.com')
    module.Domains.Add('astrallibrary.net', 'Astral Library')
    module.Domains.Add('earlymanga.net', 'EarlyManga')
    module.Domains.Add('earlymanga.website', 'EarlyManga')
    module.Domains.Add('hiperdex.com', 'Hiperdex')
    module.Domains.Add('kissmanga.link', 'KissManga')
    module.Domains.Add('mangarockteam.com', 'Manga Rock Team')
    module.Domains.Add('manhuaplus.com', 'ManhuaPLus')
    module.Domains.Add('manhuaus.com', 'Manhuaus.com')

end

function GetChapters()

    -- We need to make a POST request to get the chapters list.

    local mangaParameters = tostring(dom):regex('var\\s*manga\\s*=\\s*({.+?};)', 1)
    local mangaJson = Json.New(mangaParameters)  

    if(isempty(mangaJson['chapter_slug'])) then

        http.Headers['x-requested-with'] = 'XMLHttpRequest'
    
        http.PostData['action'] = 'manga_get_chapters'
        http.PostData['manga'] = mangaJson['manga_id']
    
        local endpoint = 'https://'..module.Domain..'/wp-admin/admin-ajax.php'
    
        dom = Dom.New(http.Post(endpoint))
    
        chapters.AddRange(dom.SelectElements('//li[contains(@class,"wp-manga-chapter")]/a'))
    
        chapters.Reverse()

    end

end
