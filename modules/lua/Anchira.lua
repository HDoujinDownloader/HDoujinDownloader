function Register()

    module.Name = 'Anchira'
    module.Adult = true

    module.Domains.Add('anchira.to')

    module.Settings.AddCheck('Data saver', false)

end

local function GetApiUrl()
    return '//api.anchira.to/'
end

local function GetApiJson(path)
   
    if(not path:startswith('//') and not path:startswith('https://')) then
        path = GetApiUrl() .. path
    end

    http.Headers['Accept'] = '*/*'
    http.Headers['Origin'] = 'https://' .. module.Domain
    http.Headers['Referer'] = 'https://' .. module.Domain .. '/'
    http.Headers['X-Requested-With'] = 'XMLHttpRequest'

    local jsonStr = http.Get(path)

    if(not jsonStr:startswith('{')) then
        
        -- We're probably encountering a reader catcha.

        Fail(Error.CaptchaRequired.WithHelpLink("https://github.com/HDoujinDownloader/HDoujinDownloader/wiki/Downloading-from-Anchira"))

    end

    return Json.New(jsonStr)
    
end

local function GetGalleryPath()
    return url:regex('\\/g\\/(.+?\\/.+?)$', 1)
end

local function IsGalleryUrl(url)
    return url:contains('/g/')
end

function GetInfo()

    if(IsGalleryUrl(url)) then

        local json = GetApiJson('library/' .. GetGalleryPath())

        info.Title = json.SelectValue('title')
        info.PageCount = json.SelectValue('pages')
        info.Tags = json.SelectValues('tags[*].name')
        info.Artist = json.SelectValues('tags[?(@.namespace==1)].name')
        
    else

        -- Assume that we added a search/tag URL instead.
        -- Add all galleries on the search page to the download queue.

        local searchParameter = GetParameter(url, "s")

        if(not isempty(searchParameter)) then

            local endpoint = '/library?s=' .. searchParameter
            local json = GetApiJson(endpoint)
           
            for entryNode in json.SelectNodes('entries[*]') do

                local id = entryNode.SelectValue('id')
                local key = entryNode.SelectValue('key')
                local url = '/g/' .. id .. '/' .. key

                Enqueue(url)

            end

            info.Ignore = true

        end

    end

end

function GetPages()

    -- local appJsUrl = dom.SelectValue('//script[contains(@src,"/_app/")]/@src')
    -- local appJs = http.Get(appJsUrl)
    -- local dataUrl = appJs:regex('DATA_URL:\\s*\\"([^"]+)', 1)

    -- We get the image file names from the gallery metadata, and the path information from the library data.

    local dataUrls = { 'kisakisexo.xyz', 'aronasexo.xyz' }

    local galleryJson = GetApiJson('library/' .. GetGalleryPath())
    local libraryJson = GetApiJson('library/' .. GetGalleryPath() .. '/data')

    local id = libraryJson.SelectValue('id')
    local key = libraryJson.SelectValue('key')
    local hash = libraryJson.SelectValue('hash')
    local server = toboolean(module.Settings['Data saver']) and 'b' or 'a'
    local imageIndex = 0

    for name in galleryJson.SelectValues('data[*].n') do
        
        local pageUrl = '//' .. dataUrls[(imageIndex % #dataUrls) + 1] .. '/' .. id .. '/' .. key .. '/' .. hash .. '/' .. server .. '/' .. EncodeUriComponent(name)

        pages.Add(pageUrl)

        imageIndex = imageIndex + 1

    end

    pages.Headers['Accept'] = '*/*'
    pages.Headers['Origin'] = 'https://' .. module.Domain
    pages.Headers['Referer'] = 'https://' .. module.Domain .. '/'

end
