function Register()

    module.Name = 'Lezhin X'
    module.Adult = true

    module.Domains.Add('lezhinx.com')

    module.Settings.AddText('Bearer token', '')

end

function GetInfo()

    local json = GetComicJson()

    info.Title = json.SelectValue('data.title')
    info.Author = json.SelectValue('data.author')
    info.Adult = toboolean(json.SelectValue('data.isAdult'))
    info.Status = toboolean(json.SelectValue('data.isComplete')) and 'Completed' or 'Ongoing'
    info.Tags = json.SelectValue('data.tag'):lower()
    info.Summary = json.SelectValue('data.synopsis')

end

function GetChapters()

    local json = GetComicJson()
    local slug = GetComicSlug()

    for episodeNode in json.SelectTokens('data.episodes[*]') do

        local episodeUrl = '/viewer/' .. slug .. '/' .. episodeNode.SelectValue('alias')
        local episodeTitle = episodeNode.SelectValue('title')

        chapters.Add(episodeUrl, episodeTitle)

    end

end

function GetPages()

    local json = GetEpisodeJson()

    pages.AddRange(json.SelectValues('data.images[*].imagePath'))

end

function GetApiUrl()

    -- https://www.lezhinx.com/balcony-api/contents/

    return 'https://www.' .. module.Domain .. '/balcony-api/contents/'
    
end

function GetApiJson(apiEndpoint)

    http.Headers['accept'] = 'application/json'
    http.Headers['referer'] = url
    http.Headers['x-balcony-id'] = 'LEZHINX_COM'
    http.Headers['x-platform'] = 'WEB'

    local bearerToken = module.Settings['Bearer token']

    if(not isempty(bearerToken)) then

        local authorizationHeader = bearerToken

        if(not authorizationHeader:startswith('Bearer ')) then
            authorizationHeader = 'Bearer ' .. authorizationHeader
        end

        http.Headers['authorization'] = authorizationHeader

    end

    return Json.New(http.Get(apiEndpoint))

end

function GetComicSlug()

    return url:regex('\\/detail\\/([^\\/?#]+)', 1)

end

function GetComicJson()

    return GetApiJson(GetApiUrl() .. GetComicSlug())

end

function GetEpisodeSlug()

    return url:regex('\\/viewer\\/([^\\/?#]+\\/\\d+)', 1)

end

function GetEpisodeJson()

    return GetApiJson(GetApiUrl() .. GetEpisodeSlug())

end
