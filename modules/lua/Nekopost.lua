function Register()

    module.Name = 'Nekopost'
    module.Language = 'Thai'

    module.Domains.Add('nekopost.net')
    module.Domains.Add('www.nekopost.net')

end

function GetInfo() 

    local json = GetGalleryJson()

    info.Status = json.SelectValue('projectInfo.np_status')
    info.Title = json.SelectValue('projectInfo.np_name')
    info.Adult = json.SelectValue('projectInfo.np_flag_mature') ~= 'N'
    info.Summary = json.SelectValue('projectInfo.np_info')
    info.DateReleased = json.SelectValue('projectInfo.np_created_date')
    info.Author = json.SelectValue('projectInfo.author_name')
    info.Artist = json.SelectValue('projectInfo.artist_name')
    info.Tags = json.SelectValue('projectCategoryUsed[*].npc_name')

    if(info.Status == '1') then
        info.Status = 'ongoing'
    else
        info.Status = 'completed'
    end

end

function GetChapters()

    local galleryId = GetGalleryId()
    local json = GetGalleryJson()

    for chapterNode in json.SelectTokens('projectChapterList[*]') do

        local chapterNumber = tostring(chapterNode['nc_chapter_no'])
        local chapterName = tostring(chapterNode['nc_chapter_name'])

        local chapterTitle = 'Ch.'..chapterNumber..' - '..chapterName
        local chapterUrl = url:trim('/')..'/'..chapterNumber
        
        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    local json = GetChapterJson()

    local galleryId = json.SelectValue('projectId')
    local chapterId = json.SelectValue('chapterId')
   
    for filename in json.SelectValues('pageItem[*].fileName') do

        local imageUrl = GetChapterApiEndpoint()..'collectManga/'..galleryId..'/'..chapterId..'/'..filename

        pages.Add(imageUrl)

    end

end

function GetGalleryId()

    return tostring(url):regex('\\/(?:comic|manga)\\/(\\d+)', 1)

end

function GetChapterId()

    return tostring(url):regex('\\/(?:comic|manga)\\/\\d+\\/([\\d\\.]+)', 1)

end

function GetGalleryApiEndpoint()

    return '//tuner.'..GetDomain(module.Domain)..'/ApiTest/'

end

function GetChapterApiEndpoint()

    return '//fs.'..GetDomain(module.Domain)..'/'

end

function GetGalleryJson()

    local apiEndpoint = GetGalleryApiEndpoint()..'getProjectDetailFull/'..GetGalleryId()
    local json = Json.New(http.Get(apiEndpoint)) 

    return json

end

function GetChapterJson()

    local galleryId = GetGalleryId()
    local chapterId = GetChapterId()
    local galleryJson = GetGalleryJson()

    -- Find the chapter id of the current chapter.

    for chapterNode in galleryJson.SelectTokens('projectChapterList[*]') do

        if(tostring(chapterNode['nc_chapter_no']) == chapterId) then

            chapterId = tostring(chapterNode['nc_chapter_id'])

            local apiEndpoint = GetChapterApiEndpoint()..'collectManga/'..galleryId..'/'..chapterId..'/'..galleryId..'_'..chapterId..'.json'
            local json = Json.New(http.Get(apiEndpoint)) 

            return json

        end

    end

end

function CleanTitle(title)

    return RegexReplace(tostring(title), '^.+?:', '')

end
