function Register()

    module.Name = 'Lezhin X'
    module.Adult = true

    module.Domains.Add('lezhin.es')
    module.Domains.Add('lezhinx.com')
    module.Domains.Add('www.lezhin.es')
    module.Domains.Add('www.lezhinx.com')

    module.Settings.AddText('Bearer token', '')

end

local function GetApiUrl()

    -- https://www.lezhinx.com/balcony-api-v2/contents/

    return 'https://www.' .. module.Domain:trim('www.') .. '/api/balcony-api-v2/contents/'
    
end

local function GetBalconyId()

    return module.Domain
        :trim('www.')
        :replace('.', '_')
        :upper()

end

local function GetApiJson(apiEndpoint)

    http.Headers['accept'] = 'application/json'
    http.Headers['referer'] = url
    http.Headers['x-balcony-id'] = GetBalconyId()
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

local function GetComicSlug()

    return url:regex('\\/(?:detail|viewer)\\/([^\\/?#]+)', 1)

end

local function GetComicJson()

    return GetApiJson(GetApiUrl() .. GetComicSlug() .. '?isNotLoginAdult=false')

end

local function GetEpisodeSlug()

    return url:regex('\\/viewer\\/([^\\/?#]+\\/[a-z\\d]+)', 1)

end

local function GetEpisodeJson()

    return GetApiJson(GetApiUrl() .. GetEpisodeSlug() .. '?isNotLoginAdult=false')

end

function GetInfo()

    local isViewerUrl = url:contains('/viewer/')

    local json = isViewerUrl and GetEpisodeJson() or GetComicJson()

    if(isViewerUrl) then
        
        info.Title = json.SelectValue('data.contentsTitle') .. ' - ' .. json.SelectValue('data.title')
        info.Tags = json.SelectValue('data.contentsTag'):lower()
        info.Summary = json.SelectValue('data.contentsSynopsis')
        info.ReadingDirection = json.SelectValue('data.paperDirection')

    else

        info.Title = json.SelectValue('data.title')
        info.Author = json.SelectValue('data.author')
        info.Status = toboolean(json.SelectValue('data.isComplete')) and 'Completed' or 'Ongoing'
        info.Tags = json.SelectValue('data.tag'):lower()
        info.Summary = json.SelectValue('data.synopsis')
    
        if(isempty(info.Author)) then
            info.Author = json.SelectValues('data.creators[*].name')        
        end

    end

    info.Adult = toboolean(json.SelectValue('data.isAdult'))

end

function GetChapters()

    if(not url:contains('/viewer/')) then
        
        local json = GetComicJson()
        local slug = GetComicSlug()
    
        for episodeNode in json.SelectTokens('data.episodes[*]') do
    
            local episodeUrl = '/viewer/' .. slug .. '/' .. episodeNode.SelectValue('alias')
            local episodeTitle = episodeNode.SelectValue('title')
    
            chapters.Add(episodeUrl, episodeTitle)
    
        end

    end

end

function GetPages()

    local json = GetEpisodeJson()

    pages.AddRange(json.SelectValues('data.images[*].imagePath'))

end
