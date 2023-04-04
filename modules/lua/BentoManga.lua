function Register()

    module.Name = 'Bentomanga'
    module.Language = 'fr'

    module.Domains.Add('bentomanga.com')
    module.Domains.Add('www.bentomanga.com')

end


function GetInfo()

    local json = GetMangaJson()

    info.Title = json.SelectValue('manga.title')
    info.Summary = json.SelectValue('manga.description')
    info.Artist = json.SelectValue('manga.artist')
    info.Author = json.SelectValue('manga.author')
    info.Status = json.SelectValue('manga.status')
    info.Tags = json.SelectValues('manga.genres[*].name')

end

function GetChapters()

    local json = GetMangaJson()
    local slug = json.SelectValue('manga.slug')
    local baseUrl = '/manga/' .. slug .. '/chapter/'

    for chapterNode in json['chapter'] do

        local chapterNumber = tostring(chapterNode['chapter'])
        local volumeNumber = tostring(chapterNode['volume'])
        local translator = tostring(chapterNode['group_name'])
        local chapterTitle = tostring(chapterNode['title'])

        local chapterInfo = ChapterInfo.New()

        chapterInfo.Title = 'Chapitre ' .. chapterNumber
        chapterInfo.Language = 'fr'
        chapterInfo.Translator = translator ~= 'null' and translator or ''
        chapterInfo.Volume = isnumber(volumeNumber) and volumeNumber or ''
        chapterInfo.Url = baseUrl .. chapterNumber

        if(not isempty(chapterTitle)) then
            chapterInfo.Title = chapterInfo.Title .. ' - ' .. chapterTitle
        end

        chapters.Add(chapterInfo)

    end

end

function GetPages()

    local json = GetChapterJson()
    local chapterId = dom.SelectValue('//meta/@data-chapter-id')

    for fileName in json.SelectValues('page_array[*]') do

        local pageUrl = '/images/mangas/chapters/' .. chapterId .. '/' .. fileName

        pages.Add(pageUrl)

    end

end

function GetApiEndpoint()

    return '/api/'

end

function SetUpApiHeaders()

    http.Headers['accept'] = 'application/json, text/plain, */*'
    http.Headers['x-requested-with'] = 'XMLHttpRequest'

end

function GetMangaJson()

    -- We need to access the reader in order to get the manga ID.
    -- We can then use the ID to access the API.

    local readerUrl = dom.SelectValue('//div[contains(@class,"manga-read")]/a/@href')

    if(not isempty(readerUrl)) then

        url = readerUrl
        dom = Dom.New(http.Get(readerUrl))

    end

    local json = GetChapterJson()  
    local mangaId = json.SelectValue('manga_id')
    local endpoint = GetApiEndpoint() .. '?id=' .. mangaId .. '&type=manga'

    SetUpApiHeaders()

    return Json.New(http.Get(endpoint))

end

function GetChapterJson()

    local chapterId = dom.SelectValue('//meta/@data-chapter-id')
    local endpoint = GetApiEndpoint() .. '?id=' .. chapterId .. '&type=chapter'

    SetUpApiHeaders()

    return Json.New(http.Get(endpoint))

end
