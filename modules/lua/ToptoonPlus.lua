function Register()

    module.Name = 'TOPTOON PLUS'
    module.Type = 'Webtoon'

    module.Domains.Add('toptoonplus.com')

    global.SetCookie(module.Domains.First(), 'already_mature', '1')

end

function GetInfo()

    local json = GetComicJson()

    info.Title = json.SelectValue('data.comic.information.title')
    info.Summary = json.SelectValue('data.comic.information.description')
    info.Author = json.SelectValues('data.comic.author[*]')

end

function GetChapters()

    local json = GetComicJson()

    for node in json.SelectTokens('data.episode[*]') do

        local episodeId = node.SelectValue('episodeId')
        local comicId = node.SelectValue('comicId')
        local chapterUrl = '/comic/' .. comicId .. '/' .. episodeId
        local chapterTitle = node.SelectValue('information.title')
        local chapterSubtitle = node.SelectValue('information.subTitle')

        if(not isempty(chapterSubtitle)) then
            chapterTitle = chapterTitle .. ' - ' .. chapterSubtitle
        end

        chapters.Add(chapterUrl, chapterTitle)

    end

end

function GetPages()

    local json = GetEpisodeJson()
    local episodeId = GetEpisodeId()

    pages.AddRange(json.SelectValues("data.episode[?(@.episodeId==" .. episodeId .. ")].contentImage.jpeg[*].path"))

end

function Login()

    local token = module.Data['token']

    if(isempty(token)) then
        
        local loginEndpoint = '//api.toptoonplus.com/auth/generateToken'

        SetupApiHeaders()

        http.PostData['auth'] = '0'
        http.PostData['deviceId'] = 'a9d4f080-4aa0-11ec-81d3-0242ac130003'
        http.PostData['is17'] = 'false'
        http.PostData['password'] = password
        http.PostData['userId'] = username

        local json = Json.New(http.Post(loginEndpoint))

        token = json.SelectValue('data.token')

        module.Data['token'] = token

        if(isempty(token)) then
            Fail(Error.LoginFailed)
        end

    end

end

function GetApiUrl()

    return 'https://api.' ..  module.Domain .. '/api/v1/'

end

function SetupApiHeaders()

    http.Headers['accept'] = 'application/json, text/plain, */*'
    http.Headers['isalreadymature'] = '1'
    http.Headers['version'] = '1.14.619a'
    http.Headers['x-api-key'] = 'SUPERCOOLAPIKEY2021#@#('

    if(not isempty(module.Data['token'])) then
        http.Headers['token'] = module.Data['token']
    end

end

function GetApiJson(path)

    SetupApiHeaders()

    local json = http.Get(GetApiUrl() .. path)

    return Json.New(json)

end

function GetComicId()

    return url:regex('\\/comic\\/(\\d+)', 1)

end

function GetEpisodeId()

    return url:regex('\\/comic\\/\\d+\\/(\\d+)', 1)

end

function GetComicJson()

    return GetApiJson('page/episode?comicId=' .. GetComicId())

end

function GetEpisodeJson()

    return GetApiJson('page/viewer?comicId=' .. GetComicId() .. '&episodeId=' .. GetEpisodeId())

end
