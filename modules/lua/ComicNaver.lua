function Register()

    module.Name = '네이버 만화'
    module.Type = 'webtoon'
    module.Language = 'kr'

    module.Domains.Add('comic.naver.com')

end

local function GetApiUrl()

    return '/api/'

end

local function SetUpApiHeaders()

    http.Headers['accept'] = 'application/json, text/plain, */*'

    if(http.Cookies.Contains('XSRF-TOKEN')) then
        http.Headers['X-Xsrf-Token'] = http.Cookies['XSRF-TOKEN']
    end
    
end

local function GetApiJson(endpoint)

    SetUpApiHeaders()

    return Json.New(http.Get(endpoint))

end

local function GetComicJson()

    local titleId = GetParameter(url, 'titleId')
    local endpoint = GetApiUrl() .. 'article/list/info?titleId=' .. titleId

    return GetApiJson(endpoint)

end

function GetInfo()

    local json = GetComicJson()

    info.Title = json.SelectValue('titleName')
    info.Author = json.SelectValues('author.writers[*].name')
    info.Artist = json.SelectValues('author.painters[*].name')
    info.Summary = json.SelectValue('synopsis')
    info.Tags = json.SelectValues('curationTagList[*].tagName')
    info.Status = json.SelectValue('finished') == 'false' and 'ongoing' or 'completed'

end

function GetChapters()

    local titleId = GetParameter(url, 'titleId')
    local pageIndex = 1
    local totalPages = 0

    repeat
        
        local endpoint = GetApiUrl() .. 'article/list?titleId=' .. titleId .. '&page=' .. pageIndex .. '&sort=DESC'
        local json = GetApiJson(endpoint)
        local episodeNodes = json.SelectTokens('articleList[*]')

        if(episodeNodes.Count() <= 0) then
            break
        end

        totalPages = tonumber(json.SelectValue('pageInfo.totalPages'))

        for episodeNode in episodeNodes do
            
            local episodeNo = episodeNode.SelectValue('no')
            local episodeSubtitle = episodeNode.SelectValue('subtitle')
            local episodeTitle = episodeNo .. ' - ' .. episodeSubtitle
            local episodeUrl = '/webtoon/detail?titleId=' .. titleId .. '&no=' .. episodeNo

            chapters.Add(episodeUrl, episodeTitle)
            
        end

        pageIndex = pageIndex + 1

    until (pageIndex > totalPages)

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"wt_viewer")]/img/@src'))

end
