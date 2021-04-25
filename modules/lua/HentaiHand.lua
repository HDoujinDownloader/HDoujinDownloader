function Register()

    module.Name = 'HentaiHand'
    module.Adult = true

    module.Domains.Add('hentaihand.com', 'HentaiHand')
    module.Domains.Add('nhentai.com', 'nHentai')

end

function GetInfo()

    local json = GetApiResponse(GetGalleryApiEndpoint())

    info.Title = json.SelectValue('title')
    info.AlternativeTitle = json.SelectValue('alternative_title')
    info.Summary = json.SelectValue('description')
    info.PageCount = json.SelectValue('pages')
    info.Type = json.SelectValues('category.name')
    info.Language = json.SelectValues('language.name')
    info.Tags = json.SelectValues('tags[*].name')
    info.Parody = json.SelectValues('parodies[*].name')
    info.Artist = json.SelectValues('artists[*].name')
    info.Author = json.SelectValues('authors[*].name')
    info.Circle = json.SelectValues('groups[*].name')
    info.Characters = json.SelectValues('characters[*].name')
    info.Status = tostring(info.Title):regex('(?i)\\((ongoing)\\)', 1)

    if(info.Summary == 'null') then
        info.Summary = ''
    end

end

function GetPages()

    local json = GetApiResponse(GetReaderApiEndpoint())

    pages.AddRange(json.SelectValues('images[*].source_url'))

end

function GetGalleryId()

    return url:regex('\\/comic\\/([^\\/?#]+)', 1)

end

function GetGalleryApiEndpoint()

    return '//'..module.Domain..'/api/comics/'..GetGalleryId()..'?nsfw=false'

end

function GetReaderApiEndpoint()

    return '//'..module.Domain..'/api/comics/'..GetGalleryId()..'/images?nsfw=false'

end

function GetApiResponse(apiEndpoint)

    http.Referer = url

    http.Headers['accept'] = 'application/json, text/plain, */*'
    http.Headers['x-csrf-token'] = dom.SelectValue('//meta[@name="csrf-token"]/@content')
    http.Headers['x-requested-with'] = 'XMLHttpRequest'

    if(not isempty(http.Cookies.GetCookie('XSRF-TOKEN'))) then
        http.Headers['x-xsrf-token'] = http.Cookies.GetCookie('XSRF-TOKEN')
    end

    return Json.New(http.Get(apiEndpoint))

end
