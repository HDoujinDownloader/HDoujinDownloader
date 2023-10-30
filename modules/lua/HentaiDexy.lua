function Register()

    module.Name = 'HentaiDexy'
    module.Adult = true

    module.Domains.Add('dexyscan.com', 'Dexyscan')
    module.Domains.Add('hentaidexy.com', 'hentaidexy')
    module.Domains.Add('hentaidexy.net', 'hentaidexy')
    
end

function GetInfo()

    local json = GetApiJson('mangas/' .. GetGalleryId())

    info.Title = json.SelectValue('manga.title')
    info.AlternativeTitle = json.SelectValues('manga.altTitles[*]')
    info.Summary = json.SelectValue('manga.summary')
    info.Author = json.SelectValues('manga.authors[*]')
    info.Adult = toboolean(json.SelectValue('manga.adultContent'))
    info.Tags = json.SelectValues('manga.genres[*]')
    info.Type = json.SelectValue('manga.type')
    info.Status = json.SelectValue('manga.status')
    info.DateReleased = json.SelectValue('manga.releaseYear')

end

function GetChapters()

    if(url:contains('/chapter/')) then
        return
    end

    local chaptersPerPage = 100
    local currentPage = 1

    while(true) do
        
        local json = GetApiJson('mangas/' .. GetGalleryId() .. '/chapters?sort=-serialNumber&limit=' .. chaptersPerPage .. '&page=' .. currentPage)
        local totalPages = json.SelectValue('totalPages')

        for chapterNode in json.SelectTokens('chapters[*]') do
            
            local chapterInfo = ChapterInfo.New()

            chapterInfo.Url = '/manga/' .. chapterNode.SelectValue('manga') .. '/chapter/' .. chapterNode.SelectValue('_id')
            chapterInfo.Title = 'Chapter ' .. chapterNode.SelectValue('serialNumber')
            chapterInfo.Volume = chapterNode.SelectValue('volume')

            chapters.Add(chapterInfo)

        end

        if(isempty(totalPages) or currentPage >= tonumber(totalPages)) then
            break
        end

        currentPage = currentPage + 1

    end

    chapters.Reverse()

end

function GetPages()

    local json = GetApiJson('chapters/' .. GetGalleryId())
    local imageHost = dom.SelectValue('//meta[contains(@property,"og:image")]/@content'):regex('.*\\/')
    
    for imageUrl in json.SelectValues('chapter.images[*]') do

        -- The image host in the URLs isn't always valid and may need to be updated.

        local fileName = imageUrl:regex('\\/([^\\/]*$)', 1)

        pages.Add(imageHost .. fileName)

    end

end

function GetGalleryId()

    if(url:contains('/chapter/')) then
        return url:regex('\\/chapter\\/([^\\/]+)', 1)
    end

    return url:regex('\\/manga\\/([^\\/]+)', 1)

end

function GetApiUrl(path)

    local apiUrl = '//backend.hentaidexy.net/api/v1'

    if(not isempty(path)) then

        if(not path:startswith('/')) then
            path = '/' .. path
        end

        apiUrl = apiUrl .. path

    end

    return apiUrl

end

function GetApiJson(path)

    http.Headers['accept'] = 'application/json, text/plain, */*'
    http.Headers['origin'] = 'https://' .. module.Domain
    http.Headers['referer'] = 'https://' .. module.Domain .. '/'

    return Json.New(http.Get(GetApiUrl(path)))

end
