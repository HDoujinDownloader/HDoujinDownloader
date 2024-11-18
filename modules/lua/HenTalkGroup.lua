function Register()

    module.Name = 'HenTalk Group'
    module.Language = 'en'
    module.Adult = true

    module.Domains.Add('fakku.cc')
    module.Domains.Add('fakkuonion.airdns.org')
    module.Domains.Add('hentalk.pw')
    module.Domains.Add('spy.fakku.cc')

end

local function GetGalleryJson()

    local galleryDataScript = dom.SelectValue('//script[contains(text(),"const data")]')
        :regex('const\\s*data\\s*=\\s.+?;')

    local js = JavaScript.New(galleryDataScript)
    local galleryJson = js.Execute('data[2]').ToJson()

    local galleryNode = galleryJson.SelectTokens('data.archive')

    if(isempty(galleryNode)) then
        galleryNode = galleryJson.SelectToken('data.gallery')
    end

    return galleryNode

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

        if(not isempty(namespace) and namespace ~= 'tag') then
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

    local hostname = url:regex('\\/\\/([^\\/]+)', 1)
    local cdnUrl = dom.SelectValue('//script[contains(text(),"PUBLIC_CDN_URL")]')
        :regex('"PUBLIC_CDN_URL":"([^"]+)"', 1)

    if(isempty(cdnUrl)) then
        cdnUrl = '//' .. hostname
    end

    if(module.Domain == 'fakkuonion.airdns.org') then

        -- Request images by page number instead of file name. 

        for pageNumber in json.SelectValues('images[*].pageNumber') do
            pages.Add(cdnUrl .. '/image/' .. hash .. '/' .. pageNumber)
        end

    else

        for fileName in json.SelectValues('images[*].filename') do
            pages.Add(cdnUrl .. '/image/' .. hash .. '/' .. fileName)
        end

    end

end
