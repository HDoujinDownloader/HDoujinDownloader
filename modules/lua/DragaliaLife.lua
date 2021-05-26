function Register()

    module.Name = 'Dragalia Life'
    module.Type = 'Webtoon'
    module.Adult = false

    module.Domains.Add('comic.dragalialost.com')

end

function GetInfo()

    info.Title = dom.Title:before('|')
    info.Language = GetWindowVariable('lang')

    if(url:contains('#detail')) then
        info.PageCount = 1
    else
        info.ChapterCount = GetChapterCount()
    end

end

function GetChapters()

    local totalChapters = tonumber(GetChapterCount())
    local pageIndex = 0

    repeat

        local endpoint = pageIndex <= 0 and '/api/index' or '/api/thumbnail_list/'..pageIndex
        local jsonPath = pageIndex <= 0 and 'items[*]' or '[*]'

        local json = GetApiResponse(endpoint)
        local chapterNodes = json.SelectTokens(jsonPath)

        if(chapterNodes.Count() <= 0) then
            break
        end

        for i = 0, chapterNodes.Count() - 1 do

            local chapterUrl = '#detail/'..tostring(chapterNodes[i]['id'])
            local chapterTitle = '#'..tostring(chapterNodes[i]['episode_num'])..' - '..tostring(chapterNodes[i]['title'])

            chapters.Add(chapterUrl, chapterTitle)

        end

        pageIndex = pageIndex + 1

    until(chapters.Count() >= totalChapters)

    chapters.Reverse()

end

function GetPages()

    local chapterId = url:regex('#detail\\/(\\d+)', 1)
    local json = GetApiResponse('/api/detail/'..chapterId)

    pages.AddRange(json.SelectValues('[*].cartoon'))

end

function GetWindowVariable(name)

    return tostring(dom):regex("window\\."..name.."\\s*\\=\\s*'([^']+)", 1)

end

function GetApiResponse(endpoint)

    http.Headers['accept'] = 'application/json, text/javascript, */*; q=0.01'
    http.Headers['x-requested-with'] = 'XMLHttpRequest'

    http.PostData['lang'] = GetWindowVariable('lang')
    http.PostData['type'] = GetWindowVariable('type')

    return Json.New(http.Post(endpoint))

end

function GetChapterCount()

    return GetApiResponse('/api/index').SelectValue('latest_comic.episode_num')

end
