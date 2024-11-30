function Register()

    module.Name = 'Kemono'
    module.Adult = true
    module.Type = 'artist cg'
    module.Strict = false

    module.Domains.Add('kemono.party')
    module.Domains.Add('kemono.su')

end

local function GetApiUrl()
    return '/api/v1/'
end

local function GetApiJson(endpoint)

    http.Headers['Accept'] = '*/*'
    http.Headers['Referer'] = url

    endpoint = GetApiUrl() .. endpoint

    return Json.New(http.Get(endpoint))

end

local function GetProfilePath()
    return url:regex('\\/\\/.+?\\/(.+?\\/user\\/\\d+)', 1)
end

local function GetPostId()
    return url:regex('\\/post\\/(\\d+)', 1)
end

local function GetPostsJson(offset)

    local endpoint = GetProfilePath() .. '/posts-legacy'

    if(offset ~= nil and offset > 0) then
        endpoint = SetParameter(endpoint, 'o', offset)
    end

    return GetApiJson(endpoint)

end

local function GetPostJson()
    return GetApiJson(GetProfilePath() .. '/post/' .. GetPostId())
end

local function GetAttachmentsAndFiles(json, pages)

    pages = pages or PageList.New()

    -- Posts have "Downloads", "Content", and "Files", in that order.
    -- For image-only posts, all the image URLs will be in the "previews" node.

    -- We may encounter URLs more than once, so ignore any duplicates.

    local seenUrls = {}

    for attachmentNode in json.SelectNodes('attachments[*]') do

        local attachmentFileName = attachmentNode.SelectValue('name')
        local attachmentPath = attachmentNode.SelectValue('path')
        local attachmentServer = attachmentNode.SelectValue('server')
        local attachmentUrl = attachmentServer .. '/data' .. attachmentPath

        if(not seenUrls[attachmentUrl]) then

            seenUrls[attachmentUrl] = true

            local pageInfo = PageInfo.New(attachmentUrl)

            pageInfo.FilenameHint = attachmentFileName
            pageInfo.Referer = 'https://' .. module.Domain .. '/'

            pages.Add(pageInfo)

        end

    end

    for attachmentNode in json.SelectNodes('previews[*]') do

        local attachmentFileName = attachmentNode.SelectValue('name')
        local attachmentPath = attachmentNode.SelectValue('path')
        local attachmentServer = attachmentNode.SelectValue('server')
        local attachmentType = attachmentNode.SelectValue('type')
        local attachmentUrl = attachmentServer .. '/data' .. attachmentPath

        -- Don't attempt to download embeds (e.g. YouTube videos).

        if(attachmentType ~= "embed" and not seenUrls[attachmentUrl]) then

            seenUrls[attachmentUrl] = true

            local pageInfo = PageInfo.New(attachmentUrl)

            pageInfo.FilenameHint = attachmentFileName
            pageInfo.Referer = 'https://' .. module.Domain .. '/'

            pages.Add(pageInfo)

        end

    end

    return pages

end

function GetInfo()

    if(url:contains('/post/')) then

        local json = GetPostJson()

        info.Title = json.SelectValue('post.title')
        info.Description = dom.SelectValue('post.content')
        info.Publisher = json.SelectValue('post.service'):title()
        info.DateReleased = json.SelectValue('post.published')
        info.Tags = json.SelectValues('post.tags[*]')
        info.PageCount = GetAttachmentsAndFiles(json).Count()

    else

        local json = GetPostsJson()

        info.Title = json.SelectValue('props.artist.name')
        info.Artist = info.Title
        info.Publisher = json.SelectValue('props.artist.service'):title()

    end

end

function GetChapters()

    -- Posts are paginated in sets of 50.

    local offset = 0
    local postCount = nil

    while(postCount == nil or offset < postCount) do

        local json = GetPostsJson(offset)

        if(postCount == nil) then
            postCount = tonumber(json.SelectValue('props.count'))
        end

        for postNode in json.SelectNodes('results[*]') do

            local userId = postNode.SelectValue('user')
            local service = postNode.SelectValue('service')
            local postId = postNode.SelectValue('id')
            local chapterTitle = postNode.SelectValue('title')
            local chapterUrl = '/' .. service .. '/user/' .. userId .. '/post/' .. postId

            chapters.Add(chapterUrl, chapterTitle)

        end

        offset = offset + tonumber(json.SelectValue('props.limit'))

    end

    chapters.Reverse()

end

function GetPages()

    local json = GetPostJson()

    GetAttachmentsAndFiles(json, pages)

end
