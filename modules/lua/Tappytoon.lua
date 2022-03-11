function Register()

    module.Name = 'Tappytoon'
    module.Type = 'Webtoon'
    
    module.Domains.Add('tappytoon.com')
    module.Domains.Add('www.tappytoon.com')

    module.Settings.AddText('Bearer token', '')

end

function GetInfo()

    local json = GetGalleryJson()
    local comicJson = json.SelectToken('..pageProps.comic')

    if(not isempty(comicJson)) then

        info.Title = comicJson['title']
        info.Summary = comicJson['longDescription']
        info.Tags = comicJson.SelectValues('genres[*].name')
        info.Author = comicJson.SelectValues('authors[*].name')

    end

    info.Language = json.SelectValues('..locale').First()
    
    -- If a chapter URL was added, we might not have a title.

    if(isempty(info.Title)) then
        info.Title = tostring(dom.Title):beforelast('-')
    end

end

function GetChapters()

    local json = GetGalleryJson()
    local chaptersJson = json.SelectToken('..entities.chapters')
    local comicId = json.SelectValue('..pageProps.comic.id')
    local baseUrl = url:before('/comics/')..'/'

    for chapterId in json.SelectValues('..get-chapters-by-comic-id-'..comicId..'-asc.response.data.result[*]') do

        local chapterJson = chaptersJson.SelectToken(chapterId)
        local chapterUnlocked = toboolean(chapterJson['isUserUnlocked']) or toboolean(chapterJson['isFree']) or toboolean(chapterJson['isUserRented'])

        if(chapterUnlocked) then

            local chapter = ChapterInfo.New()

            chapter.Title = chapterJson['title']
            chapter.Url = baseUrl..'chapters/'..chapterId
    
            chapters.Add(chapter)

        end

    end

end

function GetPages()

    local json = GetGalleryJson()
    local locale = json.SelectValues('..locale').First()
    local chapterId = json.SelectValues('..chapterId').First()
    local headersJson = json.SelectToken('..initialState.axios.headers')

    for node in headersJson do
        http.Headers[node.Key] = tostring(headersJson[node.Key])
    end
    
    local apiResponse = GetApiJson('https://api-global.tappytoon.com/chapters/'..chapterId..'?includes=images&locale='..locale)

    pages.AddRange(apiResponse.SelectValues('images[*].url'))

end

function GetGalleryJson()

    return Json.New(dom.SelectValue('//script[@id="__NEXT_DATA__"]'))    

end

function SetApiHttpHeaders()

    local bearerToken = module.Settings['Bearer token']

    if(not isempty(bearerToken)) then

        local authorizationHeader = bearerToken

        if(not authorizationHeader:startswith('Bearer ')) then
            authorizationHeader = 'Bearer ' .. authorizationHeader
        end

        http.Headers['authorization'] = authorizationHeader

    end
    
end

function GetApiJson(endpoint)

    SetApiHttpHeaders()

    return Json.New(http.Get(endpoint))

end
