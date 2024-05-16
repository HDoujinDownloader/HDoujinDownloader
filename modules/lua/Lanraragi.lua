function Register()

    module.Name = 'LANraragi'

    module.Domains.Add('hentai.fakku.cc', 'HVNC')

end

local function GetApiUrl()

    return  '/api/archives/'

end

local function SetUpApiUrl(path)

    return GetApiUrl() .. path

end

local function GetApiJson(path)

    http.Headers['accept'] = '*/*'

    local endpoint = SetUpApiUrl(path)
    local json = Json.New(http.Get(endpoint))

    return json

end

local function GetGalleryId()

    return GetParameter(url, 'id')

end

local function GetGalleryJson()

    local galleryId = GetGalleryId()
    local endpoint = galleryId .. '/metadata'

    return GetApiJson(endpoint)

end

local function GetImagesJson()

    local galleryId = GetGalleryId()
    local endpoint = galleryId .. '/files?force=false'

    return GetApiJson(endpoint)

end

function GetInfo()

    local json = GetGalleryJson()

    info.Title = json.SelectValue('title')
    info.Tags = json.SelectValue('tags'):split(',')
    info.PageCount = json.SelectValue('pagecount')

end

function GetPages()

    local json = GetImagesJson()

    pages.AddRange(json.SelectValues('pages[*]'))

end
