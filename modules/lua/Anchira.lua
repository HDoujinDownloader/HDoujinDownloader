function Register()

    module.Name = 'Anchira'
    module.Adult = true

    module.Domains.Add('anchira.to', 'Anchira')
    module.Domains.Add('koharu.to', 'Koharu')

    module.Settings.AddCheck('Data saver', false)

end

local function GetApiUrl()
    return '//api.' .. module.Domain .. '/'
end

local function GetApiJson(path, post)

    if(not path:startswith('//') and not path:startswith('https://')) then
        path = GetApiUrl() .. path
    end

    http.Headers['Accept'] = '*/*'
    http.Headers['Origin'] = 'https://' .. module.Domain
    http.Headers['Referer'] = 'https://' .. module.Domain .. '/'

    local jsonStr = post and http.Post(path) or http.Get(path)

    if(not jsonStr:startswith('{')) then
        
        -- We're probably encountering a reader catcha.

        Fail(Error.CaptchaRequired.WithHelpLink("https://github.com/HDoujinDownloader/HDoujinDownloader/wiki/Downloading-from-Anchira"))

    end

    return Json.New(jsonStr)
    
end

local function GetGalleryPath()
    return url:regex('\\/(?:g|reader)\\/([^\\/]+?\\/[^\\/#?]+)', 1)
end

local function IsGalleryUrl(url)
    return url:contains('/g/') or url:contains('/reader/')
end

local function GetTagNamespaceName(id)

    id = tostring(id)

    if(id == '8') then
        return 'male'
    elseif(id =='9') then
        return 'female'
    elseif(id == '10') then
        return 'mixed'
    elseif(id == '12') then
        return 'other'
    end

    return ''

end

function GetInfo()

    if(IsGalleryUrl(url)) then

        local json = GetApiJson('books/detail/' .. GetGalleryPath())

        info.Title = json.SelectValue('title')
        info.Artist = json.SelectValues('tags[?(@.namespace==1)].name')
        info.Circle = json.SelectValues('tags[?(@.namespace==2)].name')
        info.Magazine = json.SelectValues('tags[?(@.namespace==4)].name')
        info.Uploader = json.SelectValues('tags[?(@.namespace==7)].name')
        info.Language = json.SelectValues('tags[?(@.namespace==11)].name')
        info.PageCount = json.SelectValues('thumbnails.entries[*]').Count()

        local tags = List.New()

        for tagNode in json.SelectNodes('tags[*]') do
            
            -- Include unnamespaced tags, as well as "Male", "Female", "Mixed", and "Other".

            local tagNamespaceId = tagNode.SelectValue('namespace')

            if(isempty(tagNamespaceId) or 
                tagNamespaceId == '8' or 
                tagNamespaceId == '9' or 
                tagNamespaceId == '10' or 
                tagNamespaceId == '12') then

                local tagNamespace = GetTagNamespaceName(tagNamespaceId)
                local tagName = tagNode.SelectValue('name')

                if(isempty(tagNamespace)) then
                    tags.Add(tagName)
                else
                    tags.Add(tagNamespace .. ':' .. tagName)
                end

            end

        end

        info.Tags = tags
        
    else

        -- Assume that we added a search/tag URL instead.
        -- Add all galleries on the search page to the download queue.

        local searchParameter = GetParameter(url, "s")

        if(not isempty(searchParameter)) then

            local endpoint = '/books?s=' .. searchParameter
            local json = GetApiJson(endpoint)
           
            for entryNode in json.SelectNodes('entries[*]') do

                local id = entryNode.SelectValue('id')
                local key = entryNode.SelectValue('public_key')
                local url = '/g/' .. id .. '/' .. key

                Enqueue(url)

            end

            info.Ignore = true

        end

    end

end

function GetPages()

    local dataSaver = toboolean(module.Settings['Data saver'])
    local galleryJson = GetApiJson('books/detail/' .. GetGalleryPath())

    -- Note that not all galleries will have all resolutions available.
    -- We can't access images with resolutions that don't have a "public_key" value.

    local resolutions = dataSaver and 
        { 1280, 980, 780, 1600, 0 } or -- Prefer small resolutions
        { 0, 1600, 1280, 980, 780 } -- Prefer high resolutions (or original quality)
   
    local dataJson, dataIndex, id, key

    for _, resolution in ipairs(resolutions) do

        dataJson = galleryJson.SelectNode('data.' .. tostring(resolution))
        dataIndex = resolution
        id = dataJson.SelectValue('id')
        key = dataJson.SelectValue('public_key')

        if(not isempty(key)) then
            break
        end

    end

    local createdAt = galleryJson.SelectValue('created_at')
    local updatedAt = galleryJson.SelectValue('updated_at')

    local version = isempty(updatedAt) and createdAt or updatedAt
    local width = dataIndex

    local readerJson = GetApiJson('books/data/' .. GetGalleryPath() .. '/' .. id .. '/' .. key .. '?v=' .. version .. '&w=' .. width)
    local baseUrl = readerJson.SelectValue('base')

    for imageUrl in readerJson.SelectValues('entries[*].path') do
        pages.Add(baseUrl .. imageUrl .. '?w=' .. dataIndex)
    end

    pages.Headers['Accept'] = '*/*'
    pages.Headers['Origin'] = 'https://' .. module.Domain
    pages.Headers['Referer'] = 'https://' .. module.Domain .. '/'

end
