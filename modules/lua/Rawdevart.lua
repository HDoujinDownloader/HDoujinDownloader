function Register()

    module.Name = 'Rawdevart'
    module.Language = 'Japanese'
    module.Type = 'Manga'

    module.Domains.Add('rawdevart.art', 'Rawdevart')
    module.Domains.Add('rawdevart.com', 'Rawdevart')
    module.Domains.Add('rawsakura.com', 'RawSakura')

end

local function GetApiUrl()
    return '/spa/manga/'
end

local function GetGalleryId()
    return url:regex('-c(\\d+)(?:\\/|$)', 1)
end

local function GetChapterId()
    return url:regex('chapter-(\\d.+)(?:\\/|$)', 1)
end

local function GetGalleryJson()

    local galleryId = GetGalleryId()
    local chapterId = GetChapterId()
    local endpoint = GetApiUrl()

    if(galleryId) then
        endpoint = endpoint .. galleryId
    end

    if(chapterId) then
        endpoint = endpoint .. '/' .. chapterId
    end

    http.Headers['accept'] = 'application/json, text/plain, */*'

    local jsonStr = http.Get(endpoint)

    return Json.New(jsonStr)

end

function GetInfo()

    local json = GetGalleryJson()

    if(json.SelectNodes('chapter_detail').Count() > 0) then

        info.Title = json.SelectValue('chapter_detail.manga_name') .. ' ' .. json.SelectValue('chapter_detail.chapter_number')
        info.Tags = json.SelectValue('tags[*].tag_name')

    else

        info.Title = json.SelectValue('detail.manga_name')
        info.AlternativeTitle = json.SelectValue('detail.manga_others_name')
        info.Status = json.SelectValue('detail.manga_status') == 'false' and 'ongoing' or 'completed'
        info.Summary = json.SelectValue('detail.manga_description')
        info.DateReleased = json.SelectValue('detail.manga_date_published')
        info.Tags = json.SelectValue('tags[*].tag_name')

        info.Author = json.SelectValue('authors[*].author_name')

        if(API_VERSION > 20240919) then
            info.Genres = json.SelectValue('tags[*].tag_name')
        end

    end

end

function GetChapters()

    local json = GetGalleryJson()

    local chapterUrlBase = dom.SelectValue('//div[contains(@class,"manga-chapters")]//a/@href'):beforelast('/') .. '/'

    for chapterNode in json.SelectNodes('chapters[*]') do

        local chapterTitle = 'Chapter ' .. chapterNode.SelectValue('chapter_number')
        local chapterSubtitle = chapterNode.SelectValue('chapter_title')
        local chapterUrl = chapterUrlBase .. 'chapter-' ..  chapterNode.SelectValue('chapter_number')

        if(not isempty(chapterSubtitle)) then
            chapterTitle = chapterTitle .. ' - ' .. chapterSubtitle
        end

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    local json = GetGalleryJson()

    local server = json.SelectValue('chapter_detail.server')
    local chapterContent = json.SelectValue('chapter_detail.chapter_content')

    for imagePath in Dom.New(chapterContent).SelectValues('//canvas/@data-srcset') do

        local imageUrl = server .. imagePath

        pages.Add(imageUrl)

    end
 
end
