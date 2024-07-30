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

function GetInfo()

    if(IsGalleryUrl(url)) then

        local json = GetApiJson('books/detail/' .. GetGalleryPath())

        info.Title = json.SelectValue('title')
        info.Artist = json.SelectValues('tags[?(@.namespace==1)].name')
        info.Language = json.SelectValues('tags[?(@.namespace==11)].name')
        info.Magazine = json.SelectValues('tags[?(@.namespace==4)].name')
        info.PageCount = json.SelectValues('thumbnails.entries[*]').Count()
        info.Tags = json.SelectValues('tags[*].name')
        
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
   
    local dataIndex = dataSaver and "1280" or "0"
    local dataJson = galleryJson.SelectNode('data.' .. dataIndex)
    local id = dataJson.SelectValue('id')
    local key = dataJson.SelectValue('public_key')
    local createdAt = galleryJson.SelectValue('created_at')
    local updatedAt = galleryJson.SelectValue('updated_at')

    local version = isempty(updatedAt) and createdAt or updatedAt
    local width = dataIndex

    local readerJson = GetApiJson('books/data/' .. GetGalleryPath() .. '/' .. id .. '/' .. key .. '?v=' .. version .. '&w=' .. width)
    local baseUrl = readerJson.SelectValue('base')

    for imageUrl in readerJson.SelectValues('entries[*].path') do
        pages.Add(baseUrl .. imageUrl)
    end

    pages.Headers['Accept'] = '*/*'
    pages.Headers['Origin'] = 'https://' .. module.Domain
    pages.Headers['Referer'] = 'https://' .. module.Domain .. '/'

end
