function Register()

    module.Name = 'SussyToons'
    module.Language = 'pt-br'

    module.Domains.Add('new.sussytoons.site')
    module.Domains.Add('oldi.sussytoons.com')
    module.Domains.Add('sussyscan.com')
    module.Domains.Add('sussyscan.com')
    module.Domains.Add('sussytoons.com')
    module.Domains.Add('www.sussyscan.com')

end

local function GetApiUrl()
    return 'https://api-dev.sussytoons.site/'
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

local function GetGalleryJson()

    local mangaId = url:regex('\\/obra\\/(\\d+)', 1)

    return GetApiJson('obras/' .. mangaId)

end

local function GetReaderJson()

    local match = Regex.Match(url, '\\/capitulo\\/(?<chapterPrefix>\\d+)\\/(?<chapterId>\\d+)')
    local chapterPrefix = match['chapterPrefix']
    local chapterId = match['chapterId']

    return GetApiJson(chapterPrefix .. '/capitulos/' .. chapterId)
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
        local chapterUrl = '/capitulo/638819/' .. chapterId
        local chapterTitle = chapterNode.SelectValue('cap_nome')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    local cdnRootUrl = '//cdn.sussytoons.site/'
    local json = GetReaderJson()

    local mangaId = json.SelectValue('resultado.obra.obr_id')
    local scanId = json.SelectValue('resultado.obra.scan_id')
    local chapterNumber = json.SelectValue('resultado.cap_numero')

    for imageNode in json.SelectNodes('resultado.cap_paginas[*]') do

        local imageUrl = imageNode.SelectValue('src')
        local pageInfo = PageInfo.New()

        if(imageUrl:startswith('http')) then
            pageInfo.Url = imageUrl
        else

            pageInfo.Url = cdnRootUrl .. 'scans/' .. scanId .. '/obras/' .. mangaId .. '/capitulos/' .. chapterNumber .. '/' .. imageUrl
            pageInfo.BackupUrls.Add(cdnRootUrl .. 'wp-content/uploads/WP-manga/data/' .. imageUrl)

        end

        pages.Add(pageInfo)

    end

end
