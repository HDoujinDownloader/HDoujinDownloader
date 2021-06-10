function Register()

    module.Name = 'MangaDex'

    module.Domains.Add('mangadex.org')
    module.Domains.Add('mangadex.cc')
    module.Domains.Add('mangadex.com')

    global.SetCookie(module.Domains.First(), 'mangadex_h_toggle', '1')

end

function GetInfo()

    local json = GetGalleryJson()

    info.Title = json.SelectValue('data.attributes.title.*')
    info.AlternativeTitle = json.SelectValues('data.attributes.altTitles.*')
    info.Summary = json.SelectValue('data.attributes.description.*')
    info.Tags = json.SelectValues('data.attributes.tags[*].attributes.name.*')
    info.DateReleased = json.SelectValue('data.attributes.year')
    info.Type = json.SelectValue('data.attributes.originalLanguage')
    info.Status = json.SelectValue('data.attributes.status')
    info.Adult = json.SelectValue('data.attributes.contentRating') ~= 'safe'
    info.Author = GetRelationshipNames('author', json.SelectValues("relationships[?(@.type=='author')].id"))
    info.Artist = GetRelationshipNames('author', json.SelectValues("relationships[?(@.type=='artist')].id"))

    -- Get chapter metadata.

    if(isempty(info.Title) and url:contains('/chapter/')) then

        info.Title = GetChapterTitle(json)
        info.PageCount = json.SelectValues('data.attributes.data[*]').Count()

    end

end

function GetChapters()

    local uuid = GetGalleryUuid()
    local offset = 0
    local limit = 100
    local total = 0

    local sssMangadexPreferredLanguages = global.GetSetting('sssMangadexPreferredLanguages')
    local userLanguages = sssMangadexPreferredLanguages:split(',')
    local acceptAny = isempty(sssMangadexPreferredLanguages) or userLanguages.Count() <= 0 or userLanguages.Contains(GetLanguageId("all"))
    local groupUuids = List.New()

    repeat

        local apiEndpoint = GetApiEndpoint() .. 'chapter?manga=' .. uuid .. '&limit=' .. limit .. '&offset=' .. offset
        local json = Json.New(http.Get(apiEndpoint))
        local chapterNodes = json.SelectTokens('results[*]')

        if(chapterNodes.Count() <= 0) then
            break
        end

        for chapterNode in chapterNodes do

            local volumeNumber = tostring(chapterNode.SelectValue('data.attributes.volume'))

            if(volumeNumber == 'null') then
                volumeNumber = ''
            end

            local chapter = ChapterInfo.New()

            chapter.Title = GetChapterTitle(chapterNode)
            chapter.Url = '/chapter/' .. chapterNode.SelectValue('data.id')
            chapter.Language = chapterNode.SelectValue('data.attributes.translatedLanguage')
            chapter.ScanlationGroup = chapterNode.SelectValue("relationships[?(@.type=='scanlation_group')].id")
            chapter.Volume = volumeNumber

            if(acceptAny or userLanguages.Contains(GetLanguageId(chapter.Language))) then

                groupUuids.Add(chapter.ScanlationGroup)

                chapters.Add(chapter)

            end

        end

        if(total <= 0) then
            total = tonumber(json.SelectValue('total'))
        end

        offset = offset + limit

    until(offset >= total)

    -- Get group names.

    if(groupUuids.Count() > 0) then

        local groupsDict = BuildGroupsDict(groupUuids)

        for chapter in chapters do
            chapter.ScanlationGroup = groupsDict[chapter.ScanlationGroup]
        end

    end

end

function GetPages()

    local json = GetGalleryJson()

    local hash = tostring(json.SelectValues('data.attributes.hash'))
    local baseUrl = Json.New(http.Get(GetApiEndpoint() .. 'at-home/server/' .. GetGalleryUuid())).SelectValue('baseUrl')
    local data = json.SelectValues('data.attributes.data[*]')
    local dataSaver = json.SelectValues('data.attributes.dataSaver[*]')

    baseUrl = baseUrl .. '/data/' .. hash .. '/'

    for i = 0, data.Count() - 1 do

        local pageInfo = PageInfo.New(baseUrl .. data[i])

        if(i < dataSaver.Count()) then
            pageInfo.BackupUrls.Add(baseUrl .. dataSaver[i])
        end

        pages.Add(pageInfo)

    end

end

function GetApiEndpoint()

    return '//api.'..module.Domain..'/'

end

function GetGalleryUuid()

    return url:regex('\\/(?:title|chapter)\\/([^\\/]+)', 1)

end

function GetGalleryJson()

    local uuid = GetGalleryUuid()
    local type = url:regex('\\/(title|chapter)', 1):replace('title', 'manga')
    local apiEndpoint = GetApiEndpoint() .. type .. '/' .. uuid
    
    return Json.New(http.Get(apiEndpoint))

end

function GetChapterTitle(json)

    local result = ''

    local chapterTitle = json.SelectValue('data.attributes.title')
    local volumeNumber = tostring(json.SelectValue('data.attributes.volume'))
    local chapterNumber = tostring(json.SelectValue('data.attributes.chapter'))

    if(volumeNumber == 'null') then
        volumeNumber = ''
    end

    if(not isempty(volumeNumber)) then
        result = result .. ' Vol. ' .. volumeNumber
    end

    if(not isempty(chapterNumber)) then
        result = result .. ' Ch. ' .. chapterNumber
    end

    if(not isempty(chapterTitle)) then
        result = result .. ' - ' .. chapterTitle 
    end

    return result

end

function GetRelationshipNames(type, uuids)

    local names = List.New()

    for uuid in uuids do

        local apiEndpoint = GetApiEndpoint() .. type .. '/' .. uuid
        local json = Json.New(http.Get(apiEndpoint))

        names.Add(json.SelectValue('data.attributes.name'))

    end

    return names

end

function BuildGroupsDict(uuids)

    local groupsApiEndpoint = GetApiEndpoint() .. 'group?'

    for uuid in uuids do
        groupsApiEndpoint = groupsApiEndpoint .. 'ids[]=' .. uuid .. '&'
    end

    local groupsJson = Json.New(http.Get(groupsApiEndpoint:trim('&')))
    local groupsDict = Dict.New()

    for groupData in groupsJson.SelectTokens('results[*].data') do
        groupsDict[groupData.SelectValue('id')] = groupData.SelectValue('attributes.name')

    end

    return groupsDict

end
