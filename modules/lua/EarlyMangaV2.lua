-- EarlyManga V2 is very similar to MangaDex, and uses its own API.

function Register()

    module.Name = 'EarlyManga (V2)'
    module.Language  = 'English'

    module.Domains.Add('earlym.org', 'EarlyManga')
    module.Domains.Add('earlymanga.org', 'EarlyManga')
    module.Domains.Add('v2.earlym.org', 'EarlyManga')

end

function GetInfo()

    local slug = url:after('/manga/'):before('/')
    local json = GetApiJson(slug)

    info.Title = json.SelectValue('main_manga.title')
    info.AlternativeTitle = json.SelectValues('main_manga.alt_titles[*]')
    info.Author = json.SelectValues('main_manga.authors[*]')
    info.Artist = json.SelectValues('main_manga.artists[*]')
    info.Tags = json.SelectValues('main_manga.all_genres[*].name')
    info.Status = json.SelectValue('main_manga.pubstatus.name')
    info.Language = json.SelectValue('main_manga.language.name')
    info.Summary = json.SelectValue('main_manga.desc')

end

function GetChapters()

    local slug = url:after('/manga/'):before('/')
    local json = GetApiJson(slug .. '/chapterlist')

    for chapterNode in json do

        local chapterSlug = chapterNode.SelectValue('slug')
        local chapterNumber = chapterNode.SelectValue('chapter_number')
        local chapterSubtitle = chapterNode.SelectValue('title')
        local chapterUrl  = '/manga/' .. slug .. '/chapter-' .. chapterSlug
        local chapterTitle = 'Ch. ' .. chapterNumber
        local chapterLanguage = 'en'

        if(not isempty(chapterSubtitle) and chapterSubtitle ~= 'null') then
            chapterTitle = chapterTitle .. ' - ' .. chapterSubtitle
        end

        local chapterInfo = ChapterInfo.New()

        chapterInfo.Url = chapterUrl
        chapterInfo.Title = chapterTitle
        chapterInfo.Language = chapterLanguage

        chapters.Add(chapterInfo)

    end

    chapters.Reverse()

end

function GetPages()

    local slug = url:after('/manga/')
    local json = GetApiJson(slug)

    local mangaId = json.SelectValue('chapter.manga_id')
    local chapterSlug = json.SelectValue('chapter.slug')
    local baseUrl = '/storage/uploads/manga/manga_' .. mangaId .. '/chapter_' .. chapterSlug .. '/'

    for fileName in json.SelectValues('chapter.images[*]') do
        pages.Add(baseUrl .. fileName)
    end

end

function GetApiEndpoint()

    return '/api/manga/'

end

function GetApiJson(path)

    local endpoint = GetApiEndpoint() .. path:trim('/')

    http.Headers['Accept'] = 'application/json, text/plain, */*'
    http.Headers['X-CSRF-TOKEN'] = dom.SelectValue('//meta[@name="csrf-token"]/@content')
    http.Headers['X-Requested-With'] = 'XMLHttpRequest'

    if(not isempty(http.Cookies.GetCookie('XSRF-TOKEN'))) then
        http.Headers['X-XSRF-TOKEN'] = http.Cookies.GetCookie('XSRF-TOKEN')
    end

    return Json.New(http.Get(endpoint))

end
