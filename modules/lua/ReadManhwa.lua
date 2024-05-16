function Register()

    module.Name = 'ReadManhwa'
    module.Type = 'Manhwa'

    module.Domains.Add('readmanhwa.com', 'ReadManhwa')

end

local function GetApiBase()

    return 'https://'..module.Domain..'/api/'

end

local function GetApiJson(requestUri)

    http.Headers['accept'] = 'application/json, text/plain, */*'
    http.Headers['x-requested-with'] = 'XMLHttpRequest'
    http.Headers['x-csrf-token'] = dom.SelectValue('//meta[@name="csrf-token"]/@content')
    
    return Json.New(http.Get(requestUri))

end

local function GetSummaryJson()

    -- The "nsfw" parameter is required to access NSFW content (404 error otherwise).

    local slug = url:regex('\\/webtoon\\/([^\\/]+)', 1)

    return GetApiJson(GetApiBase()..'comics/'..slug..'?nsfw=true')   

end

local function GetChaptersJson()

    local slug = url:regex('\\/webtoon\\/([^\\/]+)', 1)

    return GetApiJson(GetApiBase()..'comics/'..slug..'/chapters?nsfw=true')   

end

local function GetImagesJson()

    local slug = url:regex('\\/webtoon\\/([^\\/]+\\/[^\\/]+)', 1)

    return GetApiJson(GetApiBase()..'comics/'..slug..'/images?nsfw=true')   

end

function GetInfo()

    info.Language = url:regex('\\/\\/.+?\\/([^\\/]+)', 1)

    if(url:contains('/reader')) then

        -- Added from reader.
        
        local json = GetImagesJson()
        
        info.Title = json.SelectValue('comic.title') .. ' - ' .. json.SelectValue('chapter.name')
        info.Summary = json.SelectValue('comic.description')
        info.Tags = json.SelectValue('tags[*].slug')
        info.PageCount = json.SelectValues('images[*].source_url').Count()

    else

        -- Added from summary.

        local json = GetSummaryJson()

        info.Title = json['title']
        info.Summary = json['description']
        info.Status = json['status']
        info.Tags = json.SelectValues('tags[*].name')
        info.Parody = json.SelectValues('parodies[*].name')
        info.Artist = json.SelectValues('artists[*].name')
        info.Author = json.SelectValues('authors[*].name')
        info.Circle = json.SelectValues('groups[*].name')
        info.Characters = json.SelectValues('characters[*].name')
        info.ChapterCount = json['chapters_count']

    end

end

function GetChapters()

    local json = GetChaptersJson()

    for token in json do
        chapters.Add(url..'/'..tostring(token['slug']), token['name'])
    end

    chapters.Reverse()

end

function GetPages()

    local json = GetImagesJson()

    pages.AddRange(json.SelectValues('images[*].source_url'))

end
