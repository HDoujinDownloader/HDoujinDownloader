function Register()

    module.Name = 'Hentaiser'
    module.Language = 'English'
    module.Adult = true

    module.Domains.Add('hentaiser.com')

end

local function GetGid()

    return tostring(url:regex('\\/book\\/([^\\/#?]+)', 1))

end

local function SetApiHttpHeaders()

    http.Headers['origin'] = 'https://app.'..module.Domain
    http.Headers['accept-language'] = 'en-US,en;q=0.9'
    http.Headers['content-type'] = 'application/json'
    http.Referer = 'https://app.'..module.Domain..'/'

end

local function GetApiUrl()

    SetApiHttpHeaders()

    local config = Json.New(http.Get('//app.'..module.Domain..'/config.json'))

    return tostring(config['urlApi'])

end

local function GetApiResponse(path)

    SetApiHttpHeaders()

    return Json.New(http.Get(GetApiUrl()..'/'..path..'/'..GetGid()))

end

function GetInfo()

    local bookJson = GetApiResponse('book')

    info.Title = bookJson['title']
    info.Tags = tostring(bookJson['tags']):split('|')
    info.PageCount = bookJson['pages']
    info.Summary = bookJson['description']
    info.Language = bookJson['lang']

end

function GetPages()

    local pagesJson = GetApiResponse('book/images')
    local mediaBaseUrl = 'https://media.'..module.Domain

    for page in pagesJson.SelectValues('[*].url') do
        pages.Add(mediaBaseUrl..page)
    end

end
