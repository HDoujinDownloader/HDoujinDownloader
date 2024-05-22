require "Madara"

function Register()

    module.Name = 'Madara (Ajax)'

    module = Module.New()

    module.Language = 'Arabic'

    module.Domains.Add('niji-translations.com', 'بحث متقدم')

    module = Module.New()

    module.Language = 'English'

    module.Domains.Add('aloalivn.com', 'Aloalivn.com')
    module.Domains.Add('astrallibrary.net', 'Astral Library')
    module.Domains.Add('earlymanga.net', 'EarlyManga')
    module.Domains.Add('earlymanga.website', 'EarlyManga')
    module.Domains.Add('fizmanga.com', 'FizManga')
    module.Domains.Add('gdegenscans.xyz', 'GD Scans')
    module.Domains.Add('hentaiwebtoon.org', 'Hentai Webtoon')
    module.Domains.Add('hmanhwa.com', 'hManhwa')
    module.Domains.Add('kissmanga.link', 'KissManga')
    module.Domains.Add('mangaforfree.net', 'MangaForFree.net')
    module.Domains.Add('mangaradar.com', 'mangaradar.com')
    module.Domains.Add('manhwaclub.net', 'manhwaclub')
    module.Domains.Add('manhwatop.com', 'MANHWATOP')
    module.Domains.Add('nightcomic.com', 'Night Comic')
    module.Domains.Add('novelmic.com', 'NovelMic')
    module.Domains.Add('platinumscans.com', 'PlatiumScans')
    module.Domains.Add('porncomixinfo.net', 'Porn Comics')
    module.Domains.Add('pornwha.com', 'Pornwha')
    module.Domains.Add('x2manga.com', 'X2MANGA')

    module = Module.New()

    module.Language = 'Spanish'

    module.Domains.Add('desuhentai.net', 'DesuHentai')

    module = Module.New()

    module.Language = 'Thai'

    module.Domains.Add('cartoon-th.com', 'Cartoon-TH')
    module.Domains.Add('wwww.cartoon-th.com', 'Cartoon-TH')

end

function GetChapters()

    -- We need to make a POST request to get the chapters list.

    local mangaParameters = tostring(dom):regex('var\\s*manga\\s*=\\s*({.+?};)', 1)
    local mangaJson = Json.New(mangaParameters)

    if(isempty(mangaJson['chapter_slug'])) then

        http.Headers['x-requested-with'] = 'XMLHttpRequest'

        http.PostData['action'] = 'manga_get_chapters'
        http.PostData['manga'] = mangaJson['manga_id']
    
        local endpoint = 'https://'..GetHost(url)..'/wp-admin/admin-ajax.php'
    
        dom = Dom.New(http.Post(endpoint))
    
        chapters.AddRange(dom.SelectElements('//li[contains(@class,"wp-manga-chapter")]/a'))
    
        chapters.Reverse()

    end

end

function Login()

    if(isempty(http.Cookies)) then

        http.Headers['accept'] = '*/*'
        http.Headers['content-type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
        http.Headers['referer'] = 'https://' .. module.Domain .. '/'
        http.Headers['x-requested-with'] = 'XMLHttpRequest'

        local loginEndpoint = '/wp-admin/admin-ajax.php'

        http.PostData.Add('action', 'wp_manga_signin')
        http.PostData.Add('login', username)
        http.PostData.Add('pass', password)
        http.PostData.Add('rememberme', 'forever')

        local response = http.PostResponse(loginEndpoint)

        if(not toboolean(Json.New(response.Body).SelectValue('success'))) then
            Fail(Error.LoginFailed)
        end

        global.SetCookies(response.Cookies)

    end

end
