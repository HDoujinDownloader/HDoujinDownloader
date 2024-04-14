function Register()

    module.Name = 'Anchira'
    module.Adult = true

    module.Domains.Add('anchira.to')

    module.Settings.AddCheck('Data saver', false)

end

local function GetApiUrl()
    return '/api/v1/'
end

local function GetApiJson(path)
   
    path = GetApiUrl() .. path

    http.Headers['Accept'] = '*/*'
    http.Headers['Referer'] = url
    http.Headers['X-Requested-With'] = 'XMLHttpRequest'

    return Json.New(http.Get(path))
    
end

local function GetGalleryPath()
    return url:regex('\\/g\\/(.+?\\/.+?)$', 1)
end

function GetInfo()

    local json = GetApiJson('library/' .. GetGalleryPath())

    info.Title = json.SelectValue('title')
    info.PageCount = json.SelectValue('pages')
    info.Tags = json.SelectValues('tags[*].name')
    info.Artist = json.SelectValues('tags[?(@.namespace==1)].name')

end

function GetPages()

    -- local appJsUrl = dom.SelectValue('//script[contains(@src,"/_app/")]/@src')
    -- local appJs = http.Get(appJsUrl)
    -- local dataUrl = appJs:regex('DATA_URL:\\s*\\"([^"]+)', 1)

    local dataUrl = '//kisakisexo.xyz'

    local json = GetApiJson('library/' .. GetGalleryPath() .. '/data')

    local id = json.SelectValue('id')
    local key = json.SelectValue('key')
    local hash = json.SelectValue('hash')
    local server = toboolean(module.Settings['Data saver']) and 'b' or 'a'

    for name in json.SelectValues('names[*]') do
        
        local pageUrl = dataUrl .. '/' .. id .. '/' .. key .. '/' .. hash .. '/' .. server .. '/' .. name

        pages.Add(pageUrl)

    end

end
