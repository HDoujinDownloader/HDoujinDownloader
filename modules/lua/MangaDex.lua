function Register()

    module.Name = 'MangaDex'

    module.Domains.Add('mangadex.org')
    module.Domains.Add('mangadex.cc')
    module.Domains.Add('mangadex.com')

    global.SetCookie(module.Domains.First(), 'mangadex_h_toggle', '1')

end

function GetInfo()

    RedirectFromOldUrl()

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

    RedirectFromOldUrl()

    local uuid = GetGalleryUuid()
    local offset = 0
    local limit = 100
    local total = 0

    local sssMangadexPreferredLanguages = global.GetSetting('sssMangadexPreferredLanguages')
    local userLanguages = sssMangadexPreferredLanguages:split(',')
    local acceptAny = isempty(sssMangadexPreferredLanguages) or userLanguages.Count() <= 0 or userLanguages.Contains(GetLanguageId("all"))
    local groupUuids = List.New()

    repeat
        -- Add contentRating to chapter call to bypass rating checks
        local apiEndpoint = GetApiEndpoint() .. 'chapter?contentRating[]=safe&contentRating[]=suggestive&contentRating[]=erotica&contentRating[]=pornographic&manga=' .. uuid .. '&limit=' .. limit .. '&offset=' .. offset
        local json = Json.New(http.Get(apiEndpoint))
        local chapterNodes = json.SelectTokens('data[*]')

        if(chapterNodes.Count() <= 0) then
            break
        end

        for chapterNode in chapterNodes do
            local chapterNumber = tostring(chapterNode.SelectValue('attributes.chapter'))
            local volumeNumber = tostring(chapterNode.SelectValue('attributes.volume'))

            if(volumeNumber == 'null') then
                volumeNumber = ''
            end

            local chapter = ChapterInfo.New()

            -- The chapters are not necessarily returned in order according to their chapter number.
            -- The chapter number is temporarily prepended to the chapter title for sorting purposes.

            chapter.Title = chapterNumber .. ' - ' .. GetChapterTitle(chapterNode)
            chapter.Url = '/chapter/' .. chapterNode.SelectValue('id')
            chapter.Language = chapterNode.SelectValue('attributes.translatedLanguage')
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

    -- Sort and remove prepended chapter numbers.

    chapters.Sort()

    for chapter in chapters do
        chapter.Title = chapter.Title:after(' - ')
    end



end

function GetPages()

    RedirectFromOldUrl()

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

    local chapterTitle = tostring(json.SelectValue('attributes.title'))
    local volumeNumber = tostring(json.SelectValue('attributes.volume'))
    local chapterNumber = tostring(json.SelectValue('attributes.chapter'))

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

    local uuidDict = Dict.New()

    -- Add all of the group UUIDs to the dict as keys, effectively filtering out the duplicates.

    for uuid in uuids do
        uuidDict[uuid] = ''
    end

    for uuid in uuidDict.Keys do
        groupsApiEndpoint = groupsApiEndpoint .. 'ids[]=' .. uuid .. '&'
    end

    -- This was adding a blank id on the end of the query for some reason.  If it's present it causes a 400 and prevents the download, so lets just remove it
    local groupsJson = Json.New(http.Get(groupsApiEndpoint:trim('&ids[]=&')))

    for groupData in groupsJson.SelectTokens('data[*]') do
        uuidDict[groupData.SelectValue('id')] = groupData.SelectValue('attributes.name')

    end

    return uuidDict

end

function RedirectFromOldUrl()

    if(not GetGalleryUuid():contains("-")) then

        -- We have an old URL and need to follow the redirect to the new one.
        -- Ex: https://mangadex.org/title/45502/veil

        url = http.GetResponse(url).Url

    end

end
