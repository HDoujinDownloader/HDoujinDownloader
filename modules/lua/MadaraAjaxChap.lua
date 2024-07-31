-- This module is extremely similar to MadaraAjax, except the POST request arguments are different.

require "MadaraAjax"

function Register()

    module.Name = 'Madara (Ajax Chap)'

    module = Module.New()

    module.Language = 'en'

    module.Domains.Add('manhwahentai.me', 'ManhwaHentai.me')

end

function GetChapters()

    local mangaParameters = dom.SelectValue('//script[contains(text(),"comicObj")]')
        :regex('comicObj\\s*=\\s*([^;]+)', 1)

    local mangaJson = Json.New(mangaParameters)   

    if(isempty(mangaJson['chapter_slug'])) then

        http.Headers['x-requested-with'] = 'XMLHttpRequest'

        http.PostData['action'] = 'ajax_chap'
        http.PostData['post_id'] = mangaJson['post_id']
    
        local endpoint = 'https://'..GetHost(url)..'/wp-admin/admin-ajax.php'
    
        dom = Dom.New(http.Post(endpoint))
    
        chapters.AddRange(dom.SelectElements('//li[contains(@class,"wp-manga-chapter")]/a'))
    
        chapters.Reverse()

    end

end
