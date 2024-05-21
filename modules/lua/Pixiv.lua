function Register()

    module.Name = 'Pixiv'
    module.Type = 'Artist CG'
    
    -- Because artworks can be made up of multiple images, we'll often have more images than expected.

    module.Strict = false

    module.Domains.Add('pixiv.net')
    module.Domains.Add('www.pixiv.net')

end

local function GetPreloadJson()

    local jsonStr = dom.SelectValue('//meta[@id="meta-preload-data"]/@content')

    if(isempty(jsonStr)) then

        Fail(Error.LoginRequired)

    end

    return Json.New(jsonStr)

end

local function GetUserArtworksJson()

    local json = GetPreloadJson()
    local userId = json.SelectValue('user..userId')
    local apiEndpoint = '/ajax/user/' .. userId .. '/profile/all'

    return Json.New(http.Get(apiEndpoint))

end

local function GetArtworkImagesJson(artworkId)

    if(artworkId == nil) then

        local json = GetPreloadJson()

        artworkId = json.SelectValue('illust..illustId')

    end

    local apiEndpoint = '/ajax/illust/' .. artworkId .. '/pages'

    return Json.New(http.Get(apiEndpoint))

end

function GetInfo()

    local json = GetPreloadJson()

    if(url:contains('/users/')) then

        -- Added user gallery.

        info.Artist = json.SelectValue('user..name')
        info.Summary = json.SelectValue('user..comment')

        json = GetUserArtworksJson()

        if(url:contains('/manga')) then

            -- Added "manga" tab.
            -- Treat each manga as its own chapter.

            info.Title = info.Artist .. '\'s manga'
            info.ChapterCount = json.SelectToken('body.manga').Count()

        else

            -- Added "illustrations" tab.

            info.Title = info.Artist .. '\'s illustrations'
            info.PageCount = json.SelectToken('body.illusts').Count()

        end

    elseif(url:contains('/artworks/')) then

        -- Added a single illustration/manga.

        info.Title = json.SelectValue('illust..illustTitle')
        info.Artist = json.SelectValue('illust..userName')
        info.Summary = json.SelectValue('illust..description')
        info.Tags = json.SelectValues('illust..tags.tags[*].tag')
        info.DateReleased = json.SelectValue('illust..createDate')
        info.PageCount = json.SelectValue('illust..pageCount')
        info.Adult = List.New(info.Tags).Contains('R-18')

    end

end

function GetPages()

    if(url:contains('/users/')) then

        -- Added user gallery.

        local json = GetUserArtworksJson()

        for node in json.SelectToken('body.illusts') do

            local artworkId = node.Key
            local artworkJson = GetArtworkImagesJson(artworkId)

            pages.AddRange(artworkJson.SelectValues('body[*].urls.original'))

        end

        -- Reverse the image list so that oldest images are listed first.

        pages.Reverse()

    elseif(url:contains('/artworks/')) then

        -- Added a single illustration/manga.

        local json = GetArtworkImagesJson()

        pages.AddRange(json.SelectValues('body[*].urls.original'))

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
