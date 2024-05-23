function Register()

    module.Name = 'ComicK'

    module.Domains.Add('comick.app')
    module.Domains.Add('comick.cc')
    module.Domains.Add('comick.fun')
    module.Domains.Add('comick.ink')
    module.Domains.Add('comick.io')

end

local function GetComicSlug()

    return url:regex('\\/comic\\/([^\\/]+)', 1)

end

local function GetChapterHid()

    return url:regex('\\/comic\\/[^\\/]+\\/([^\\-]+)', 1)

end

local function GetApiUrl()

    return '//api.' .. module.Domain .. '/'

end

local function SetUpApiHeaders()

    http.Headers['Accept'] = '*/*'
    http.Headers['Origin'] = GetRoot(url):trim('/')
    http.Headers['Referer'] = GetRoot(url)

end

local function GetApiJson(endpoint)

    SetUpApiHeaders()

    return Json.New(http.Get(GetApiUrl() .. endpoint))

end

function GetInfo()

    local json = GetApiJson('comic/' .. GetComicSlug())

    info.Title = json.SelectValue('comic.title')
    info.Status = json.SelectValue('comic.status') == '2' and 'Completed' or 'Ongoing'
    info.Adult = toboolean(json.SelectValue('comic.hentai'))
    info.Summary = json.SelectValue('comic.desc')
    info.AlternativeTitle = json.SelectValues('comic.md_titles[*].title')
    info.Tags = json.SelectValues('comic.md_comic_md_genres[*].md_genres.name')
    info.Artist = json.SelectValues('artists[*].name')
    info.Author = json.SelectValues('authors[*].name')

end

function GetChapters()

    local chapterPageNumber = 1
    local totalChapters = 0

    repeat

        local json = GetApiJson('comic/' .. GetComicSlug())
        local slug = json.SelectValue('comic.slug')
        local hid = json.SelectValue('comic.hid')
    
        json = GetApiJson('comic/' .. hid .. '/chapters?page=' .. chapterPageNumber)

        totalChapters = tonumber(json.SelectValue('total'))

        local chapterNodes = json.SelectNodes('chapters[*]')
    
        if(chapterNodes.Count() <= 0) then
            return
        end

        for chapterNode in chapterNodes do
    
            local title = chapterNode.SelectValue('title')
            local chapterNumber = chapterNode.SelectValue('chap')
            local volumeNumber = chapterNode.SelectValue('vol')
            local translator = chapterNode.SelectValues('group_name[*]')
            local language = chapterNode.SelectValue('lang')
            local hid = chapterNode.SelectValue('hid')
            
            local chapterInfo = ChapterInfo.New()
    
            chapterInfo.Title = 'Ch. ' .. chapterNumber .. ' ' .. title
            chapterInfo.Volume = volumeNumber
            chapterInfo.Translator = translator
            chapterInfo.Language = language
            chapterInfo.Url = '/comic/' .. slug .. '/' .. hid .. '-chapter-' .. chapterNumber .. '-' .. language
    
            chapters.Add(chapterInfo)
    
        end

        chapterPageNumber = chapterPageNumber + 1

    until(chapters.Count() >= totalChapters)

    chapters.Reverse()

end

function GetPages()

    local json = GetApiJson('chapter/' .. GetChapterHid())
    local imagesPath = GetRoot(dom.SelectValue('//meta[contains(@property,"og:image")]/@content'))

    if(isempty(imagesPath)) then
        imagesPath = '//meo.comick.pictures/'
    end

    for fileName in json.SelectValues('chapter.md_images[*].b2key') do
    
        local imageUrl = imagesPath .. fileName

        pages.Add(imageUrl)

    end
    
end
