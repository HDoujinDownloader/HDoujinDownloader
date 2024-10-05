function Register()

    module.Name = 'ManhwaWeb'
    module.Language = 'Spanish'
    module.Type = 'Manhwa'

    module.Domains.Add('manhwaweb.com')

end

local function GetApiUrl()
    return '//manhwawebbackend-production.up.railway.app/'
end

local function GetApiJson(path)

    local endpoint = GetApiUrl() .. path

    http.Headers['accept'] = 'application/json, text/plain, */*'
    http.Headers['origin'] = 'https://' .. module.Domain
    http.Headers['referer'] = 'https://manhwaweb.com/' .. module.Domain .. '/'

    local jsonStr = http.Get(endpoint)

    return Json.New(jsonStr)

end

local function GetGallerySlug()
    return url:regex('\\/(?:manga|manhwa|leer)\\/([^\\/?#]+)', 1)
end

local function GetGalleryJson()

    local gallerySlug = GetGallerySlug()
    local endpoint = 'manhwa/see/' .. gallerySlug

    return GetApiJson(endpoint)

end

local function GetChapterJson()

    local gallerySlug = GetGallerySlug()
    local endpoint = 'chapters/see/' .. gallerySlug

    return GetApiJson(endpoint)

end

function GetInfo()

    local json = GetGalleryJson()

    info.Title = json.SelectValue('the_real_name')
    info.Author = json.SelectValue('_extras.autores[*]')
    info.Tags = json.SelectValue('_categoris[*].*')
    info.Adult = json.SelectValue('_erotico')  == 'yes'
    info.Summary = json.SelectValue('_sinopsis')
    info.Status = json.SelectValue('_status')
    info.Type = json.SelectValue('_tipo')
    info.Publisher = json.SelectValue('_plataforma'):title()

end

function GetChapters()

    local json = GetGalleryJson()

    for chapterNode in json.SelectNodes('chapters[*]') do

        local chapterNumber = chapterNode.SelectValue('chapter')
        local chapterUrl = chapterNode.SelectValue('link')
        local chapterTitle = 'Capitulo ' .. chapterNumber

        chapters.Add(chapterUrl, chapterTitle)

    end

end

function GetPages()

    local json = GetChapterJson()

    pages.AddRange(json.SelectValues('chapter.img[*]'))

end
