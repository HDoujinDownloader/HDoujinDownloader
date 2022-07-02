function Register()

    module.Name = '9hentai'

    module.Domains.Add('9hentai.com')
    module.Domains.Add('9hentai.ru')
    module.Domains.Add('9hentai.to')

    module.Adult = true

end

function GetInfo()

    info.Title = dom.SelectValue('//div[@id="info"]/h1')
    info.Tags = dom.SelectValues('//section[@id="tags"]/div[contains(text(),"Tag")]//a')
    info.Circle = dom.SelectValues('//section[@id="tags"]/div[contains(text(),"Group")]//a')
    info.Artist = dom.SelectValues('//section[@id="tags"]/div[contains(text(),"Artist")]//a')
    info.Type = dom.SelectValues('//section[@id="tags"]/div[contains(text(),"Category")]//a')
    info.Language = dom.SelectValues('//section[@id="tags"]/div[contains(text(),"Language")]//a')

end

function GetPages()

    local json = GetGalleryJson()

    local totalPages = tonumber(json.SelectValue('results.total_page'))
    local imageServer = json.SelectValue('results.image_server')
    local galleryId = GetGalleryId()
    local fileExtension = '.jpg'

    for i = 1, totalPages do
        pages.Add(imageServer..galleryId..'/'..i..fileExtension)
    end

end

function GetGalleryId()

    return url:regex('\\/g\\/(\\d+)', 1)

end

local function GetApiEndpoint()

    return GetRoot(url) .. 'api/getBookByID'

end

function GetGalleryJson()

    local apiEndpoint = GetApiEndpoint()
    
    http.Headers['content-type'] = 'application/json;charset=UTF-8'
    http.Headers['origin'] = GetRoot(url)
    http.Headers['x-csrf-token'] = dom.SelectValue('//meta[@name="csrf-token"]/@content')
    http.Headers['x-requested-with'] = 'XMLHttpRequest'

    if(not isempty(http.Cookies.GetCookie('XSRF-TOKEN'))) then
        http.Headers['x-xsrf-token'] = http.Cookies.GetCookie('XSRF-TOKEN')
    end

    local json = http.Post(apiEndpoint, '{"id":'..GetGalleryId()..'}')
    
    return Json.New(json)

end
