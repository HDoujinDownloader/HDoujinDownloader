function Register()

    module.Name = 'Manta Comics'
    module.Type = 'webtoon'

    module.Domains.Add('manta.net')

end

function GetInfo()

    local json = GetComicJson()

    info.Title = json.SelectValue('data.data.title.en')  
    info.Author = json.SelectValue("data.data.creators[?(@.role == 'Writer')].name")
    info.Artist = json.SelectValue("data.data.creators[?(@.role == 'Illustration')].name")
    info.Translator = json.SelectValue("data.data.creators[?(@.role == 'Localization')].name")

    if(toboolean(json.SelectValue('data.data.isCompleted'))) then
        info.Status = 'completed'
    else
        info.Status = 'ongoing'
    end

end

function GetChapters()

    local json = GetComicJson()

    for episodeNode in json.SelectTokens('data.episodes[*]') do

        local episodeId = episodeNode.SelectValue('id')
        local episodeNumber = episodeNode.SelectValue('ord')
        local episodeTitle = 'Episode '.. episodeNumber
        local episodeUrl = '/episodes/' .. episodeId

        chapters.Add(episodeUrl, episodeTitle)

    end

end

function GetPages()

    local json = GetEpisodeJson()

    pages.AddRange(json.SelectValues('data.cutImages[*].downloadUrl'))

end

local function GetApiUrl()

    return '/front/v1/'

end

local function SetUpApiUrl(path)

    return GetApiUrl() .. path

end

local function GetApiJson(path)

    http.Headers['accept'] = '*/*'
    
    local endpoint = SetUpApiUrl(path)
    local json = Json.New(http.Get(endpoint))

    return json

end

local function GetComicId()

    return url:regex('series\\/(\\d+)', 1)

end

local function GetEpisodeId()

    return url:regex('episodes\\/(\\d+)', 1)

end

function GetComicJson()

    local endpoint = 'series/' .. GetComicId()

    return GetApiJson(endpoint)

end

function GetEpisodeJson()

    local endpoint = 'episodes/' .. GetEpisodeId()

    return GetApiJson(endpoint)

end
