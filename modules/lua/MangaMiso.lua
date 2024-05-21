function Register()

    module.Name = 'MangaMiso'
    module.Type = 'manga'
    module.Language = 'English'

    module.Domains.Add('mangamiso.net')

end

local function GetApiUrl()

    -- https://mangamiso.net/mangas/

    return 'https://' .. module.Domain .. '/mangas/'

end

local function GetApiJson(requestUrl)

    http.Headers['accept'] = 'application/json, text/plain, */*'

    return Json.New(http.Get(requestUrl))

end

local function GetMangaJson()

    local js = JavaScript.New()
    local mangaJs = dom.SelectValue('//script[contains(text(),"__NUXT__")]')
    
    js.Execute('window = {}')
    js.Execute(mangaJs)

    local mangaJson = Json.New(js.GetObject('window.__NUXT__').ToJson())

    return mangaJson.SelectToken('data[*].manga')

end

local function GetChaptersJson(pageIndex)

    local slug = url:regex('\\/manga\\/([^\\/#?]+)', 1)
    local perPage = 50
    local apiUrl = GetApiUrl() .. slug .. '/get-manga-chapters-12345?page=' .. tostring(pageIndex) .. '&perPage=' .. tostring(perPage) .. '&sort=-1'

    local json = GetApiJson(apiUrl)

    return json

end

local function GetPagesJson()

    local slug = url:regex('\\/manga\\/(.+?\\/[^\\/#?]+)', 1)
    local perPage = 50
    local apiUrl = GetApiUrl() .. slug

    local json = GetApiJson(apiUrl)

    return json

end

function GetInfo()

    local mangaJson = GetMangaJson()

    info.Title = mangaJson.SelectValue('title')
    info.AlternativeTitle = mangaJson.SelectValue('alternateTitles')
    info.Description = mangaJson.SelectValue('description')
    info.Status = mangaJson.SelectValue('status')
    info.DateReleased = mangaJson.SelectValue('releaseDate')
    info.Author = mangaJson.SelectValues('author[*]')
    info.Artist = mangaJson.SelectValues('artist[*]')
    info.Tags = mangaJson.SelectValues('genre[*]')

    info.Author = tostring(info.Author):replace('_', ' ')
    info.Artist = tostring(info.Artist):replace('_', ' ')
    info.Tags = tostring(info.Tags):replace('_', ' ')

end

function GetChapters()

    for i = 1, 100 do

        local chaptersJson = GetChaptersJson(i)
        local totalChapters = tonumber(chaptersJson.SelectValue('chapters.totalChapters'))
        local chapterNodes = chaptersJson.SelectTokens('chapters.chapters[*]')

        for j = 0, chapterNodes.Count() - 1 do
    
            local chapterNode = chapterNodes[j]
            local chapterNumber = chapterNode.SelectValue('chapterNum')
            local chapterVolume = chapterNode.SelectValue('volNum')
            local chapterUrl = url:trim('/') .. '/' .. chapterNode.SelectValue('pathName')
            local chapterSubtitle = chapterNode.SelectValue('chapterTitle')
            local chapterTitle = 'Chapter ' .. chapterNumber
    
            if(not isempty(chapterVolume)) then
                chapterTitle = 'Vol.' .. chapterVolume .. ' - ' .. chapterTitle
            end
    
            if(not chapterSubtitle:startswith('Chapter ')) then
                chapterTitle = chapterTitle .. ' ' .. chapterSubtitle
            end

            chapters.Add(chapterUrl, chapterTitle)
    
        end

        if chapters.Count() >= totalChapters then break end
    
    end

    chapters.Reverse()

end

function GetPages()

    local pagesJson = GetPagesJson()

    pages.AddRange(pagesJson.SelectValues('chapter.pages[*].path'))

end
