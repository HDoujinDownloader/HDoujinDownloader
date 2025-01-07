function Register()

    module.Name = 'SussyToons'
    module.Language = 'pt-br'

    module.Domains.Add('new.sussytoons.site')

end

local function GetApiUrl()
    return 'https://api-dev.' .. GetDomain(module.Domain) .. '/'
end

local function GetApiJson(endpoint)

    http.Headers['accept'] = 'application/json, text/plain, */*'
    http.Headers['accept-language'] = 'pt-br,pt;q=0.9,en-us;q=0.8,en;q=0.7'
    http.Headers['origin'] = 'https://' .. module.Domain
    http.Headers['referer'] = 'https://' .. module.Domain .. '/'
    http.Headers['scan-id'] = '1'

    endpoint = GetApiUrl() .. endpoint

    return Json.New(http.Get(endpoint))

end

local function GetGalleryId()
    return url:regex('\\/(?:obra|capitulo)\\/([^\\/]+)', 1)
end

local function GetGalleryJson()
    return GetApiJson('obras/' .. GetGalleryId())
end

local function GetReaderJson()
    return GetApiJson('capitulos/' .. GetGalleryId())
end

function GetInfo()

    local json = GetGalleryJson()

    info.Title = json.SelectValue('resultado.obr_nome')
    info.Description = json.SelectValue('resultado.obr_descricao')
    info.Status = json.SelectValue('resultado.status.stt_nome')
    info.Type = json.SelectValue('resultado.formato.formt_nome')

end

function GetChapters()

    local json = GetGalleryJson()

    for chapterNode in json.SelectNodes('resultado.capitulos[*]') do

        local chapterId = chapterNode.SelectValue('cap_id')
        local chapterUrl = '/capitulo/' .. chapterId
        local chapterTitle = chapterNode.SelectValue('cap_nome')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    local cdnRootUrl = '//oldi.' .. GetDomain(module.Domain) .. '/'
    local json = GetReaderJson()

    for imageNode in json.SelectNodes('resultado.cap_paginas[*]') do

        local imageUrl = imageNode.SelectValue('src')

        if(not imageUrl:startswith('http')) then
            imageUrl = cdnRootUrl .. 'wp-content/uploads/WP-manga/data/' .. imageUrl
        end

        pages.Add(imageUrl)

    end

end
