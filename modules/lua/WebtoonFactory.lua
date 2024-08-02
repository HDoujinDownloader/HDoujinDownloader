function Register()

    module.Name = 'WebtoonFactory'

    module.Type = 'webtoon'
    module.Language = 'en'

    module.Domains.Add('webtoonfactory.com')
    module.Domains.Add('www.webtoonfactory.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Summary = dom.SelectValue('//div[contains(@class,"serie_desc")]')
    info.Author = dom.SelectValues('//div[contains(@class,"authors")]//span[contains(@class,"name")]')

end

function GetChapters()

    local languageCode = url:regex('\\/(.{2})\\/', 1)

    if(isempty(languageCode)) then
        languageCode = 'en'
    end

    for episodeNode in dom.SelectNodes('//div[@data-episode]') do
        
        local dataEpisode = episodeNode.SelectValue('./@data-episode')
        local episodeTitle = 'Episode ' .. (chapters.Count() + 1) .. ' - ' .. episodeNode.SelectValue('.//h3')
        local episodeUrl = '/' .. languageCode .. '/dispatcher/episodes/' .. dataEpisode

        chapters.Add(episodeUrl, episodeTitle)    

    end

end

function GetPages()

    http.Headers['Accept'] = '*/*'
    http.Headers['Referer'] = 'https://' .. module.Domain .. '/'

    local json = Json.New(http.Get(url))
    local dom = Dom.New(json.SelectValue('webtoon.html'))

    pages.AddRange(dom.SelectValues('//div[contains(@class,"webtoon__reader")]//img/@data-src'))

end
