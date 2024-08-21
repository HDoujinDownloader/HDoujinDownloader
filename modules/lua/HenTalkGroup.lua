function Register()

    module.Name = 'HenTalk Group'
    module.Language = 'en'
    module.Adult = true

    module.Domains.Add('fakku.cc')
    module.Domains.Add('hentalk.pw')
    module.Domains.Add('spy.fakku.cc')

end

local function GetGalleryJson()

    local galleryDataScript = dom.SelectValue('//script[contains(text(),"const data")]')
        :regex('const\\s*data\\s*=\\s.+?;')

    local js = JavaScript.New(galleryDataScript)
    local galleryJson = js.Execute('data[2]').ToJson()

    return galleryJson.SelectToken('..archive')

end

function GetInfo()

    local json = GetGalleryJson()

    info.Title = json.SelectValue('title')
    info.Summary = json.SelectValue('description')
    info.Artist = json.SelectValues('artists[*].name')
    info.Magazine = json.SelectValues('magazines[*].name')

    local tags = List.New()

    for tagNode in json.SelectNodes('tags[*]') do

        local namespace = tagNode.SelectValue('namespace')
        local name = tagNode.SelectValue('name')

        if(not isempty(namespace)) then
            tags.Add(namespace .. ':' .. name)
        else
            tags.Add(name)
        end

    end

    info.Tags = tags

end

function GetPages()

    local json = GetGalleryJson()
    local hash = json.SelectValue('hash')

    local cdnUrl = dom.SelectValue('//script[contains(text(),"PUBLIC_CDN_URL")]')
        :regex('"PUBLIC_CDN_URL":"([^"]+)"', 1)

        if(isempty(cdnUrl)) then
            cdnUrl = '//cdn.fakku.cc'
        end

    for fileName in json.SelectValues('images[*].filename') do
        pages.Add(cdnUrl .. '/image/' .. hash .. '/' .. fileName)
    end

end
