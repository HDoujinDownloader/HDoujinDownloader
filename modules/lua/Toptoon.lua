function Register()

    module.Name = 'Toptoon'
    module.Language = 'ko'
    module.Type = 'webtoon'

    module.Domains.Add('toptoon.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//span[@title]')
    info.Author = dom.SelectValue('//span[contains(@class,"comic_wt")]')
    info.Summary = dom.SelectValue('//p[contains(@class,"story_synop")]')

end

function GetChapters()

    local baseUrl = url
        :before('?')
        :replace('/ep_list/', '/ep_view/')
        :trim('/')
        .. '/'

    for episodeNode in dom.SelectElements('//a[@data-episode-id]') do

        local episodeUrl = baseUrl .. episodeNode.SelectValue('@data-episode-id')
        local episodeTitle = episodeNode.SelectValue('.//p[contains(@class,"episode_title")]')
        local episodeSubtitle = episodeNode.SelectValue('.//p[contains(@class,"episode_stitle")]')

        if(not isempty(episodeSubtitle)) then
            episodeTitle = episodeTitle .. episodeSubtitle
        end

        chapters.Add(episodeUrl, episodeTitle)

    end
    
end

function GetPages()

    pages.AddRange(dom.SelectValues('//img[contains(@class,"document_img")]/@data-src'))

end
