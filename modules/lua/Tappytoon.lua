function Register()

    module.Name = 'Tappytoon'
    module.Type = 'Webtoon'
    
    module.Domains.Add('tappytoon.com')
    module.Domains.Add('www.tappytoon.com')

    module.Settings.AddText('Bearer token', '')

end

local function GetGalleryJson()
    return Json.New(dom.SelectValue('//script[@id="__NEXT_DATA__"]'))
end

local function SetApiHttpHeaders()

    -- Get headers from current page first
    local json = GetGalleryJson()
    local headersJson = json.SelectToken('props.initialState.axios.headers')
    
    if(not isempty(headersJson)) then

        for node in headersJson do
            http.Headers[node.Key] = tostring(headersJson[node.Key])
        end

    end
    
    -- Override with bearer token from settings if provided
    local bearerToken = module.Settings['Bearer token']

    if(not isempty(bearerToken)) then

        local authorizationHeader = bearerToken

        if(not authorizationHeader:startswith('Bearer ')) then
            authorizationHeader = 'Bearer ' .. authorizationHeader
        end

        http.Headers['Authorization'] = authorizationHeader

    end

end

local function GetApiJson(endpoint)

    SetApiHttpHeaders()

    return Json.New(http.Get(endpoint))

end

function GetInfo()

    local json = GetGalleryJson()
    local comicJson = json.SelectToken('props.initialProps.pageProps.comic')

    if(not isempty(comicJson)) then

        info.Title = comicJson['title']
        info.Summary = comicJson['longDescription']
        info.Tags = comicJson.SelectValues('genres[*].name')
        info.Author = comicJson.SelectValues('authors[*].name')
        info.Language = comicJson['locale']

    end
    
    -- If a chapter URL was added, we might not have a title.
    if(isempty(info.Title)) then

        local titlePart = tostring(dom.Title):afterlast('-')

        if(not isempty(titlePart)) then

            info.Title = titlePart:beforelast('|'):trim()

        else

            info.Title = tostring(dom.Title):beforelast('|'):trim()

        end

    end

end

function GetChapters()

    local json = GetGalleryJson()
    local comicId = json.SelectValue('props.initialProps.pageProps.comic.id')
    
    local baseUrl = url:regex('(^.+?)\\/(?:comic|book)\\/', 1) .. '/'
    
    local apiResponse = GetApiJson('https://api-global.tappytoon.com/comics/' .. tostring(comicId) .. '/chapters')
    
    for chapterJson in apiResponse.SelectTokens('[*]') do

        local isAccessible = toboolean(chapterJson['isAccessible'])
        
        if(isAccessible) then

            local chapter = ChapterInfo.New()

            chapter.Title = chapterJson['title']
            
            chapter.Url = baseUrl .. 'chapters/' .. tostring(chapterJson['id'])
    
            chapters.Add(chapter)
            
        end

    end

end

function GetPages()

    local json = GetGalleryJson()
    local locale = json.SelectValue('props.initialProps.pageProps.comic.locale')

    if(isempty(locale)) then
        locale = 'en'
    end
    
    local chapterId = json.SelectValue('props.initialProps.pageProps.chapterId')
    
    -- Set headers from the page
    local headersJson = json.SelectToken('props.initialState.axios.headers')

    for node in headersJson do
        http.Headers[node.Key] = tostring(headersJson[node.Key])
    end
    
    -- Get comic ID from entities to check quality support
    local chapterJson = json.SelectToken('props.initialState.entities.chapters.' .. tostring(chapterId))
    local comicId = chapterJson['comicId']
    local comicJson = json.SelectToken('props.initialState.entities.comics.' .. tostring(comicId))
    
    -- Determine quality
    local quality = 'high'

    if(not isempty(comicJson) and toboolean(comicJson['isSuperHighQualitySupported'])) then
        quality = 'super_high'
    end
    
    local apiResponse = GetApiJson('https://api-global.tappytoon.com/content-delivery/contents?chapterId=' .. tostring(chapterId) .. '&variant=' .. quality .. '&locale=' .. tostring(locale))

    pages.AddRange(apiResponse.SelectValues('media[*].url'))

end