function Register()

    module.Name = 'Pixiv'
    module.Type = 'Artist CG'

    -- Because artworks can be made up of multiple images, we'll often have more images than expected.

    module.Strict = false

    module.Domains.Add('pixiv.net')
    module.Domains.Add('www.pixiv.net')

    module.Settings.AddCheck('Use Japanese tags', false)

end

local function GetPreloadJson()

    local jsonStr = dom.SelectValue('//meta[@id="meta-preload-data"]/@content')

    if(isempty(jsonStr)) then
        Fail(Error.LoginRequired)
    end

    return Json.New(jsonStr)

end

local function GetArtworkId()

    local json = GetPreloadJson()

    return json.SelectValue('illust..illustId')

end

local function GetUserArtworksJson()

    local json = GetPreloadJson()
    local userId = json.SelectValue('user..userId')
    local apiEndpoint = '/ajax/user/' .. userId .. '/profile/all'

    return Json.New(http.Get(apiEndpoint))

end

local function GetUserArtworkIds()

    local json = GetUserArtworksJson()
    local artworkIds = {}

    local includeManga = url:contains('/manga')
    local includeIllustrations = url:contains('/illustrations')
    local includeAll = not (includeManga or includeIllustrations)

    if(includeManga or includeAll) then

        for node in json.SelectToken('body.manga') do
            table.insert(artworkIds, tonumber(node.Key))
        end

    end

    if(includeIllustrations or includeAll) then

        for node in json.SelectToken('body.illusts') do
            table.insert(artworkIds, tonumber(node.Key))
        end

    end

    table.sort(artworkIds)

    return artworkIds

end

local function GetArtworkImagesJson(artworkId)

    artworkId = artworkId or GetArtworkId()

    local apiEndpoint = '/ajax/illust/' .. artworkId .. '/pages'

    return Json.New(http.Get(apiEndpoint))

end

local function GetUgoiraMetadataJson(artworkId)

    artworkId = artworkId or GetArtworkId()

    local apiEndpoint = '/ajax/illust/' .. artworkId .. '/ugoira_meta'

    return Json.New(http.Get(apiEndpoint))

end

local function GetArtworkImagesPages(artworkId)

    local preloadJson = GetPreloadJson()

    local artworkTitle = preloadJson.SelectValue('illust..illustTitle')
    local artworkType = preloadJson.SelectValue('illust..illustType')

    if(tostring(artworkType) == '2') then

        -- We have a Ugoira artwork.

        local json = GetUgoiraMetadataJson(artworkId)
        local archiveUrl = json.SelectValue('body.originalSrc')

        local pageInfo = PageInfo.New(archiveUrl)

        pageInfo.Title = artworkTitle

        pages.Add(pageInfo)

    else

        -- We have a single image/multiple image artwork.

        local json = GetArtworkImagesJson(artworkId)

        for imageUrl in json.SelectValues('body[*].urls.original') do

            local pageInfo = PageInfo.New(imageUrl)

            pageInfo.Title = artworkTitle

            pages.Add(pageInfo)

        end

    end

end

function GetInfo()

    local json = GetPreloadJson()

    if(url:contains('/users/')) then

        -- Added user gallery.

        info.Artist = json.SelectValue('user..name')
        info.Summary = json.SelectValue('user..comment')

        local artworkIds = GetUserArtworkIds()

        if(url:contains('/manga')) then

            -- Added "manga" tab.
            -- Treat each manga as its own chapter.

            info.Title = info.Artist .. '\'s manga'
            info.ChapterCount = #artworkIds

        elseif(url:contains('/illustrations')) then

            -- Added "illustrations" tab.

            info.Title = info.Artist .. '\'s illustrations'
            info.PageCount = #artworkIds

        else

            -- Consider all artworks (e.g. "Home" tab, or "artworks" page).

            info.Title = info.Artist
            info.PageCount = #artworkIds

        end

    elseif(url:contains('/artworks/')) then

        -- Added a single illustration/manga.

        info.Title = json.SelectValue('illust..illustTitle')
        info.Artist = json.SelectValue('illust..userName')
        info.Summary = json.SelectValue('illust..description')
        info.DateReleased = json.SelectValue('illust..createDate')
        info.PageCount = json.SelectValue('illust..pageCount')
        info.Adult = List.New(info.Tags).Contains('R-18')

        if(toboolean(module.Settings['Use Japanese tags'])) then

            -- Get Japanese tags.

            info.Tags = json.SelectValues('illust..tags.tags[*].tag')

        else

            -- Get English tags.

            local tagsList = List.New()

            for tagNode in json.SelectNodes('illust..tags.tags[*]') do

                local tagName = tagNode.SelectValue('translation.en')

                if(isempty(tagName)) then
                    tagName = tagNode.SelectValue('romaji')
                end

                if(isempty(tagName)) then
                    tagName = tagNode.SelectValue('tag')
                end

                if(not isempty(tagName)) then
                    tagsList.Add(tagName)
                end

            end

            info.Tags = tagsList

        end

    end

end

function GetPages()

    if(url:contains('/users/')) then

        -- Added user gallery.

        local artworkIds = GetUserArtworkIds()

        if(API_VERSION < 20241109) then

            -- This is the "old" way of enumerating the artwork images.
            -- Newer versions of HDoujin don't require us to get all of the image URLs upfront.

            for _, artworkId in ipairs(artworkIds) do

                local artworkImagesJson = GetArtworkImagesJson(artworkId)

                pages.AddRange(artworkImagesJson.SelectValues('body[*].urls.original'))

            end

        else

            -- Enumerate the artwork URLs and get the direct image URLs later.

            local baseUrl = url:before('/users/') .. '/artworks/'

            for _, artworkId in ipairs(artworkIds) do
                pages.Add(baseUrl .. artworkId)
            end

        end

    elseif(url:contains('/artworks/')) then

        -- Added a single illustration/manga.

        GetArtworkImagesPages()

        -- If the artwork is NSFW, we won't be able to get any images without signing in.

        if(isempty(pages)) then
            Fail(Error.LoginRequired)
        end

    end

end

function GetChapters()

    local json = GetPreloadJson()
    local userId = json.SelectValue('user..userId')
    local artworkIds = List.New()

    json = GetUserArtworksJson()

    for node in json.SelectToken('body.manga') do
        artworkIds.Add(node.Key)
    end

    -- We'll have a list of all artwork IDs, but no titles.
    -- We need to request the artwork metadata in batches.

    local batchSize = 48

    for i = 0, artworkIds.Count() - 1, batchSize do

        local apiEndpoint = '/ajax/user/' .. userId .. '/profile/illusts?'

        for j = i, math.min(i + batchSize, artworkIds.Count()) - 1 do

            if(j > i) then
                apiEndpoint = apiEndpoint .. '&'
            end

            apiEndpoint = apiEndpoint .. 'ids%5B%5D=' .. artworkIds[j]

        end

        apiEndpoint = apiEndpoint .. '&work_category=manga&is_first_page=1'

        -- Get the metadata for this batch.

        json = Json.New(http.Get(apiEndpoint))

        local artworkNodes = json.SelectToken('body..works')

        for j = 0, artworkNodes.Count() - 1 do

            local node = artworkNodes[j]

            local artworkId = node.SelectValue('..id')
            local artworkTitle = node.SelectValue('..title')
            local artworkUrl = '/en/artworks/' .. artworkId

            chapters.Add(artworkUrl, artworkTitle)

        end

    end

    -- Reverse the chapter list so that older items are listed first.

    chapters.Reverse()

end

function BeforeDownloadPage()

    if(not url:contains('/artworks/')) then
        return
    end

    -- Get the direct image URLs.

    GetArtworkImagesPages()

end
