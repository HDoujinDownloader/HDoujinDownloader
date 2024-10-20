function Register()

    module.Name = 'MangaLib'
    module.Language = 'Russian'

    module.Domains.Add('hentailib.me', 'HentaiLib')
    module.Domains.Add('hentailib.org', 'HentaiLib')
    module.Domains.Add('mangalib.me', 'MangaLib')
    module.Domains.Add('mangalib.org', 'MangaLib')
    module.Domains.Add('ranobelib.me', 'RanobeLib')
    module.Domains.Add('v1.hentailib.org', 'HentaiLib')

end

local function GetGallerySlug()
   return url:regex('\\/(?:ru\\/manga|ru)\\/([^\\/#?^\\s]+)', 1)
end

local function GetApiUrl()

    local apiDomain = 'api.' .. module.Domain

    if(module.Name == 'MangaLib') then
        apiDomain = 'api.mangalib.me'
    elseif(module.Name == 'HentaiLib') then
        apiDomain = 'api.lib.social'
    end

    return '//' .. apiDomain .. '/api/'

end

local function GetApiJson(endpoint)

    http.Headers['Accept'] = '*/*'
    http.Headers['Content-Type'] = 'application/json'
    http.Headers['Origin'] = 'https://' .. module.Domain
    http.Headers['Referer'] = 'https://' .. module.Domain .. '/'

    if(module.Name == 'MangaLib') then
        http.Headers['Site-Id'] = '1'
    elseif(module.Name == 'HentaiLib') then
        http.Headers['Site-Id'] = '4'
    end

    local jsonStr = http.Get(endpoint)

    return Json.New(jsonStr)

end

local function GetGalleryJson()

    local slug = GetGallerySlug()
    local endpoint = GetApiUrl() .. 'manga/' .. slug .. '?fields[]=background&fields[]=eng_name&fields[]=otherNames&fields[]=summary&fields[]=releaseDate&fields[]=type_id&fields[]=caution&fields[]=views&fields[]=close_view&fields[]=rate_avg&fields[]=rate&fields[]=genres&fields[]=tags&fields[]=teams&fields[]=user&fields[]=franchise&fields[]=authors&fields[]=publisher&fields[]=userRating&fields[]=moderated&fields[]=metadata&fields[]=metadata.count&fields[]=metadata.close_comments&fields[]=manga_status_id&fields[]=chap_count&fields[]=status_id&fields[]=artists&fields[]=format'

    return GetApiJson(endpoint)

end

local function GetChapterJson()

    local slug = GetGallerySlug()
    local volumeNumber = url:regex('\\/read\\/v(\\d+)', 1)
    local chapterNumber = url:regex('\\/read\\/.+?\\/c(\\d+)', 1)

    local chapterJson = GetApiJson('manga/' .. slug .. '/chapter?number=' .. chapterNumber .. '&volume=' .. volumeNumber)

    return chapterJson

end

function GetInfo()

    if(url:contains('/read/')) then

        -- A chapter URL was added.

        local json = GetChapterJson()

        local volumeNumber = json.SelectValue('data.volume')
        local chapterNumber = json.SelectValue('data.number')
        local chapterSubtitle = json.SelectValue('data.name')
        local chapterTitle = 'Том ' .. volumeNumber .. ' Глава ' .. chapterNumber

        if(not isempty(chapterSubtitle)) then
            chapterTitle = chapterTitle .. ' - ' .. chapterSubtitle
        end

        info.Title = chapterTitle

    else

        -- A gallery URL was added.

        local json = GetGalleryJson()

        info.Title = json.SelectValue('data.rus_name')
        info.OriginalTitle = json.SelectValue('data.name')
        info.AlternativeTitle = json.SelectValues('data.otherNames[*]')
        info.Summary = json.SelectValue('data.summary')
        info.DateReleased = json.SelectValue('data.releaseDate')
        info.Translator = json.SelectValues('data.teams[*].name')
        info.Tags = json.SelectValues('data.genres[*].name')

    end

end

function GetChapters()

    local slug = GetGallerySlug()
    local json = GetApiJson('manga/' .. slug .. '/chapters')

    for chapterNode in json.SelectNodes('data[*]') do

        local volumeNumber = chapterNode.SelectValue('volume')
        local chapterNumber = chapterNode.SelectValue('number')
        local chapterSubtitle = chapterNode.SelectValue('name')
        local chapterUrl = '/ru/' .. slug .. '/read/v' .. volumeNumber .. '/c' .. chapterNumber
        local chapterTitle = 'Том ' .. volumeNumber .. ' Глава ' .. chapterNumber

        if(not isempty(chapterSubtitle)) then
            chapterTitle = chapterTitle .. ' - ' .. chapterSubtitle
        end

        local chapter = ChapterInfo.New()

        chapter.Title = chapterTitle
        chapter.Url = chapterUrl
        chapter.Volume = volumeNumber

        chapters.Add(chapter)

    end

end

function GetPages()

    local imageServersJson = GetApiJson('constants?fields[]=imageServers')
    local chapterJson = GetChapterJson()

    local mainImageServer = imageServersJson.SelectValue('data.imageServers[0].url')
    local secondaryImageServer = imageServersJson.SelectValue('data.imageServers[1].url')

    for imageUrl in chapterJson.SelectValues('data.pages[*].url') do

        local page = PageInfo.New()

        page.Url = mainImageServer .. imageUrl

        page.BackupUrls.Add(secondaryImageServer .. imageUrl)

        pages.Add(page)

    end

end
