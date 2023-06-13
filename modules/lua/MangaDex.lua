function Register()

    module.Name = 'MangaDex'

    module.Domains.Add('mangadex.org')
    module.Domains.Add('mangadex.cc')
    module.Domains.Add('mangadex.com')

    global.SetCookie(module.Domains.First(), 'mangadex_h_toggle', '1')

    if(API_VERSION >= 3) then

        BuildLanguageSelection(module)

        module.Settings.AddCheck('Prefer scanlation status over publishing status', false)
            .WithToolTip('If enabled, the scanlation status will be used instead of the publishing status in the metadata.')

    end

--[[     -- The following rate limits are from:
    -- https://api.mangadex.org/docs/rate-limits/

    if(API_VERSION >= 20230612) then

        module.RateLimits.Add('api.' .. module.Domains.First(), 5, 1000)
        module.RateLimits.Add('/at-home/server/', 40, 60000)

        -- There are no specified rate limits for this endpoint, but let's play it safe for now.
        -- Users have been reporting issues with MangaDex returning incorrect images (#216).

        module.RateLimits.Add('uploads.' .. module.Domains.First(), 5, 1000)

    end ]]

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
    info.Author = json.SelectValues("data.relationships[?(@.type=='author')].attributes.name")

    if(toboolean(module.Settings['Prefer scanlation status over publishing status'])) then

        -- For more information, see:
        -- https://github.com/HDoujinDownloader/HDoujinDownloader/issues/76

        local scanlationStatus = GetScanlationStatus(json)

        if(not isempty(scanlationStatus)) then
            info.Status = scanlationStatus
        end

    end

    -- Get chapter metadata.

    if(isempty(info.Title) and url:contains('/chapter/')) then
        info.Title = GetChapterTitle(json.SelectNode('data'))
    end

end

function GetChapters()

    RedirectFromOldUrl()

    local uuid = GetGalleryUuid()
    local offset = 0
    local limit = 100
    local total = 0

    local userLanguages = GetPreferredLanguages()
    local acceptAny = userLanguages.Count() <= 0 or userLanguages.Contains(GetLanguageId("all"))
    local groupUuids = List.New()

    repeat

        -- Add contentRating to chapter call to bypass rating checks

        PrepareHttpHeaders()

        local apiEndpoint = GetApiEndpoint() .. 'chapter?contentRating[]=safe&contentRating[]=suggestive&contentRating[]=erotica&contentRating[]=pornographic&manga=' .. uuid .. '&limit=' .. limit .. '&offset=' .. offset .. '&includes[]=scanlation_group'
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
        
            -- Some chapters are located on external sites like bilibilicomics.com.
            -- e.g. /title/8798e5d3-b383-459e-9606-9550c6340f4d/the-dictator
            
            local externalUrl = chapterNode.SelectValue('attributes.externalUrl')

            if(not isempty(externalUrl) and externalUrl ~= 'null') then
                chapter.Url = externalUrl
            else
                chapter.Url = '/chapter/' .. chapterNode.SelectValue('id')
            end

            chapter.Title = chapterNumber .. ' - ' .. GetChapterTitle(chapterNode)         
            chapter.Language = chapterNode.SelectValue('attributes.translatedLanguage')
            chapter.ScanlationGroup = chapterNode.SelectValues("relationships[?(@.type=='scanlation_group')].attributes.name")
            chapter.Chapter = chapterNumber
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

    -- Sort and remove prepended chapter numbers.

    chapters.Sort()

    for chapter in chapters do
        chapter.Title = chapter.Title:after(' - ')
    end

end

function GetPages()

    -- The APIs used in this method are thoroughly described here:
    -- https://api.mangadex.org/docs/retrieving-chapter/

    RedirectFromOldUrl()

    PrepareHttpHeaders()

    local json = Json.New(http.Get(GetApiEndpoint() .. 'at-home/server/' .. GetGalleryUuid() .. '?forcePort443=false'))

    local hash = json.SelectValue('chapter.hash')
    local baseUrl = json.SelectValue('baseUrl')
    local data = json.SelectValues('chapter.data[*]')
    local dataSaver = json.SelectValues('chapter.dataSaver[*]')

    for i = 0, data.Count() - 1 do

        local pageInfo = PageInfo.New(baseUrl .. '/data/' .. hash .. '/' .. data[i])

        if(i < dataSaver.Count()) then
            pageInfo.BackupUrls.Add(baseUrl .. '/data-saver/' .. hash .. '/' .. dataSaver[i])
        end

        pages.Add(pageInfo)

    end

    -- Attempt to replicate the image request headers as closely as possible.

    pages.Referer = 'https://' .. module.Domain .. '/'

    if(API_VERSION >= 20230612) then

        pages.Headers['accept'] = '*/*'

    end

end

function GetApiEndpoint()

    return '//api.' .. module.Domain .. '/'

end

function GetGalleryUuid()

    return url:regex('\\/(?:title|chapter)\\/([^\\/?#]+)', 1)

end

function PrepareHttpHeaders()

    http.Headers['accept'] = '*/*'

end

function GetGalleryJson()

    PrepareHttpHeaders()

    local uuid = GetGalleryUuid()
    local type = url:regex('\\/(title|chapter)', 1):replace('title', 'manga')
    local apiEndpoint = GetApiEndpoint() .. type .. '/' .. uuid .. '?includes[]=artist&includes[]=author&includes[]=scanlation_group'

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

    if(chapterNumber == 'null') then
        chapterNumber = ''
    end

    if(chapterTitle == 'null') then
        chapterTitle = ''
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

        PrepareHttpHeaders()

        local apiEndpoint = GetApiEndpoint() .. type .. '/' .. uuid
        local json = Json.New(http.Get(apiEndpoint))

        names.Add(json.SelectValue('data.attributes.name'))

    end

    return names

end

function BuildGroupsDict(uuids)

    PrepareHttpHeaders()

    local groupsApiEndpoint = GetApiEndpoint() .. 'group?'

    local uuidDict = Dict.New()

    -- Add all of the group UUIDs to the dict as keys, effectively filtering out the duplicates.

    for uuid in uuids do
        uuidDict[uuid] = ''
    end

    for uuid in uuidDict.Keys do
        groupsApiEndpoint = groupsApiEndpoint .. 'ids[]=' .. uuid .. '&'
    end

    if uuidDict.Keys.Count() > 0 then
        
        -- This was adding a blank id on the end of the query for some reason.  If it's present it causes a 400 and prevents the download, so lets just remove it
        local groupsJson = Json.New(http.Get(groupsApiEndpoint:trim('&ids[]=&')))
        
        for groupData in groupsJson.SelectTokens('data[*]') do
            uuidDict[groupData.SelectValue('id')] = groupData.SelectValue('attributes.name')
        end

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

function GetScanlationStatus(json)

    local lastChapterNumber = json.SelectValue('data.attributes.lastChapter')
    local lastVolumeNumber = json.SelectValue('data.attributes.lastVolume')

    if(lastVolumeNumber == 'null') then
        lastVolumeNumber = ''
    end

    chapters = ChapterList.New()

    GetChapters()

    if(isempty(chapters)) then
        return 'ongoing'
    end

    -- We can't just check the most recent chapter, because sometimes there is content uploaded after the last chapter.
    -- See https://github.com/HDoujinDownloader/HDoujinDownloader/issues/76#issuecomment-1065185376
    -- Sometimes the "lastVolume" property will be null, in which case we should just check the chapter number.

    for chapter in chapters do

        if(chapter.Chapter == lastChapterNumber and (isempty(lastVolumeNumber) or chapter.Volume == lastVolumeNumber)) then
            return 'completed'
        end

    end

    return 'ongoing'

end

function BuildLanguageSelection(module)

    local options = { 
        "All", 
        "sa", "bd", "bg", "mm", "ct", "cn", "hk", "cz", "dk", "nl", 
        "gb", "ph", "fi", "fr", "de", "gr", "hu", "id", "it", "jp", 
        "kr", "my", "mn", "ir", "pl", "br", "pt", "ro", "ru", "rs", 
        "es", "mx", "se", "th", "tr", "ua", "vn", "hi", "fa"
    }

    for i = 2, #options do
        options[i] = GetLanguageName(options[i])
    end

    local oldSettingName = 'sssMangadexPreferredLanguages'
    local oldSettingValue = global.GetSetting(oldSettingName)
    local defaultSettingValue = nil

    if(not isempty(oldSettingValue)) then

        local languageIds = oldSettingValue:split(',')

        for i = 0, languageIds.Count() - 1 do
            languageIds[i] = GetLanguageName(languageIds[i])
        end

        defaultSettingValue = tostring(languageIds)

    end

    local setting = module.Settings.AddChoice('Preferred language(s)', defaultSettingValue, options)
        .WithMultiSelect()

    setting.Options.Sort()

end

function GetPreferredLanguages()

    local preferredLanguagesStr = module.Settings['Preferred language(s)']
    local modulePreferredLanguageSettingIsSet = not isempty(preferredLanguagesStr)

    if(not modulePreferredLanguageSettingIsSet) then
        preferredLanguagesStr = global.GetSetting('sssMangadexPreferredLanguages')
    end

    if(isempty(preferredLanguagesStr)) then
        return List.New()
    end

    local preferredLanguages = preferredLanguagesStr:split(',')

    if(modulePreferredLanguageSettingIsSet) then

        for i = 0, preferredLanguages.Count() - 1 do
            preferredLanguages[i] = tostring(GetLanguageId(preferredLanguages[i]))
        end

    end

    return preferredLanguages

end
