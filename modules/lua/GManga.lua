function Register()

    module.Name = 'GMANGA'
    module.Language = 'arabic'

    module.Domains.Add('gmanga.me')

end

function GetInfo() 

    local json = GetApiJson('mangas/' .. GetGalleryId())

    info.Title = json.SelectValue('mangaData.title')
    info.OriginalTitle = json.SelectValue('mangaData.japanese')
    info.AlternativeTitle = json.SelectValue('mangaData.english')
    info.Summary = json.SelectValue('mangaData.summary')
    info.Type = json.SelectValue('mangaData.type.name')
    info.ReadingDirection = json.SelectValue('mangaData.type.reading_direction')
    info.Author = json.SelectValue('mangaData.authors[*]')
    info.Artist = json.SelectValue('mangaData.artists[*]')

end

function GetChapters()

    local galleryId = GetGalleryId()
    local gallerySlug = GetGallerySlug()
    local json = GetApiJson('mangas/' .. galleryId .. '/releases')
    local teamDict = BuildTeamDict(json)

    for node in json.SelectNodes('releases[*]') do
        
        local chapterNumber = node.SelectValue('chapter')
        local chapterId = node.SelectValue('id')
        local chapterTeam = teamDict[node.SelectValue('team_id')]
        local chapterTitle = 'Chapter ' .. chapterNumber
        local chapterUrl = '/mangas/' .. galleryId .. '/' .. gallerySlug .. '/' .. chapterNumber .. '/' .. chapterId

        local chapterInfo = ChapterInfo.New()

        chapterInfo.Title = chapterTitle
        chapterInfo.Url = chapterUrl
        chapterInfo.Translator = chapterTeam

        chapters.Add(chapterInfo)

    end

    chapters.Reverse()

end

function GetPages()

    local json = Json.New(dom.SelectValue('//script[contains(@data-component-name,"HomeApp")]'))
    local imagesPath = json.SelectValue('readerDataAction.readerData.release.storage_key')

    for fileName in json.SelectValues('readerDataAction.readerData.release.pages[*]') do
        
        local imageUrl = '//media.' .. module.Domain .. '/uploads/releases/' .. imagesPath .. '/hq/' .. fileName

        pages.Add(imageUrl)

    end
end

function GetApiUrl(path)

    local endpoint = '//api2.' .. module.Domain .. '/api/'

    if(not isempty(path)) then
        endpoint = endpoint .. path:trim('/')
    end
 
    return endpoint

end

function GetApiJson(path)

    http.Headers['accept'] = 'application/json'
    http.Headers['content-type'] = 'application/json'
    http.Headers['origin'] = 'https://' .. module.Domain
    http.Headers['referer'] = 'https://' .. module.Domain .. '/'

    return Json.New(http.Get(GetApiUrl(path)))

end

function GetGalleryId()

    return url:regex('\\/mangas\\/([^\\/]+)', 1)

end

function GetGallerySlug()

    return url:regex('\\/mangas\\/[^\\/]+\\/([^\\/]+)', 1)

end

function BuildTeamDict(json)

    local dict = Dict.New()

    for node in json.SelectNodes('teams[*]') do
        
        local teamId = node.SelectValue('id')
        local teamName = node.SelectValue('name')

        dict[teamId] = teamName

    end

    return dict

end
