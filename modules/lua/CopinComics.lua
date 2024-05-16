function Register()

    module.Name = 'Copin Comics'
    module.Language = 'en'
    module.Type = 'webtoon'

    module.Domains.Add('copincomics.com')

end

local function GetApplicationJson()

    local jsonStr = dom.SelectValue('//script[@id="__NEXT_DATA__"]')

    return Json.New(jsonStr)

end

local function GetApiResponse(endpoint)

    http.Headers['accept'] = 'application/json, text/plain, */*'
    http.Headers['platform'] = 'PC_WEB'
    http.Headers['rate'] = 'ALL'

    return Json.New(http.Get(endpoint))

end

function GetInfo()

    local json = GetApplicationJson()

    info.Title = json.SelectValue('props.pageProps.titleInfo.titleName')
    info.Summary = json.SelectValue('props.pageProps.titleInfo.description')
    info.Author = json.SelectValue('props.pageProps.titleInfo.authors[*].name')
    info.Tags = json.SelectValue('props.pageProps.titleInfo.tags[*].tagWord')

end

function GetChapters()

    local json = GetApplicationJson()
    local titlePKey = json.SelectValue('props.pageProps.titlePKey')

    local apiEndpoint = '//toon-api.copincomics.com/episodes?titlePKey=' .. titlePKey .. '&sort=EPISODE_DESC&page=0&pageSize=1000'
    local episodesJson = GetApiResponse(apiEndpoint)

    for node in episodesJson.SelectTokens('content[*]') do

        local episodeTitle = node.SelectValue('episodeTitle')
        local episodeSubtitle = node.SelectValue('episodeTitle2')
        local episodePKey = node.SelectValue('episodePKey')
        local episodeUrl = '/toon/' .. titlePKey .. '/' .. episodePKey

        if(not isempty(episodeSubtitle)) then
            episodeTitle = episodeTitle .. ' - ' .. episodeSubtitle
        end

        chapters.Add(episodeUrl, episodeTitle)

    end

    chapters.Reverse()

end

function GetPages()

    local json = GetApplicationJson()
    local episodePKey = json.SelectValue('query.pkey')

    -- Get an auth token.

    local apiEndpoint = '//api.copincomics.com/v/checkAuth.json?k=' .. episodePKey .. '&paymethod=ticketrent&t='
    local authJson = GetApiResponse(apiEndpoint)
    local authToken = authJson.SelectValue('body.vt')

    -- Get the image list.

    apiEndpoint = '//api.copincomics.com/v/vt.json?vt=' .. authToken .. '&t='
    json = GetApiResponse(apiEndpoint)

    pages.AddRange(json.SelectValues('body.imgs[*]'))

end
