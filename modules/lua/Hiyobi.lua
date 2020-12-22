function Register()

    module.Name = 'hiyobi.me'
    module.Adult = true

    module.Domains.Add('hiyobi.me')

end

function GetInfo()

    http.Headers['content-type'] = 'application/json'

    local galleryId = GetGalleryId(url)
    local apiUrl = '//api.'..module.Domain..'/gallery/'..galleryId
    local json = Json.New(http.Get(apiUrl))

    info.Title = json['title']
    info.Artist = tostring(json.SelectValues('artists[*].value')):title()
    info.Circle = tostring(json.SelectValues('groups[*].value')):title()
    info.Parody = tostring(json.SelectValues('parodys[*].value')):title()
    info.Characters = tostring(json.SelectValues('characters[*].value')):title()
    info.Tags = json.SelectValues('tags[*].value')
    info.Language = json['language']

    local type = tonumber(json['type'])

    if(type == 1) then
        info.Type = 'doujinshi'
    elseif(type == 2) then
        info.Type = 'manga'
    elseif(type == 3) then
        info.Type = 'artistcg'
    end

end

function GetPages()

    http.Headers['content-type'] = 'application/json'

    local galleryId = GetGalleryId(url)
    local cdnUrl = '//cdn.'..module.Domain
    local apiUrl = cdnUrl..'/json/'..galleryId..'_list.json'
    local json = Json.New(http.Get(apiUrl))

    for filename in json.SelectValues('[*].name') do

        local imageUrl = cdnUrl..'/data/'..galleryId..'/'..filename

        pages.Add(imageUrl)

    end

end

function GetGalleryId(url)

    return tostring(url):regex('\\/reader\\/(.+?)$', 1)

end
