function Register()

    module.Name = 'Porn-Comic'
    module.Language = 'en'
    module.Adult = true

    module.Domains.Add('cool-comics.com')
    module.Domains.Add('cool-manga.com')
    module.Domains.Add('porn-comic.com')
    module.Domains.Add('www.cool-manga.com')

end

local function GetApiUrl()

    return '//cool-comics.com/ajax_h/'

end

local function GetApiJson(endpoint)

    http.Headers['accept'] = 'application/json, text/javascript, */*; q=0.01'
    http.Headers['x-requested-with'] = 'XMLHttpRequest'

    return Json.New(http.Get(GetApiUrl() .. endpoint))

end

local function GetGalleryId()

    return url:regex('\\/h\\/(\\d+)', 1)

end

local function GetPageCount()

    return dom.SelectValue('//div[contains(@id,"pages")]//a[last()-1]')

end

local function GetPageJson(index)

    local galleryId = GetGalleryId()
    local endpoint = galleryId .. '-' .. index .. '.html?ajax=1'

    return GetApiJson(endpoint)

end

function GetInfo()

    info.Title = dom.SelectValue('//h2')
    info.Type = dom.SelectValue('//a[contains(@rel,"category tag")]')
    info.Parody = dom.SelectValues('//span[contains(text(),"Anime/Game:")]/a')
    info.Characters = dom.SelectValues('//span[contains(text(),"Characters:")]/a')
    info.Artist = dom.SelectValues('//span[contains(text(),"Artist:")]/a')
    info.Tags = dom.SelectValues('//span[contains(text(),"Tags")]/a')
    info.PageCount = GetPageCount()

end

function GetPages()

    for i = 1, GetPageCount() do

        local json = GetPageJson(i)
        local imageUrl = Dom.New(json.SelectValue('pic')).SelectValue('//img/@src')

        pages.Add(imageUrl)

    end

end
