function Register()

    module.Name = '네이버 만화'
    module.Type = 'webtoon'
    module.Language = 'korean'

    module.Domains.Add('comic.naver.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//span[contains(@class,"title")]')
    info.Artist = dom.SelectValue('//span[contains(@class,"wrt_nm")]'):split('/')
    info.Summary = dom.SelectValue('//div[contains(@class,"detail")]/p')
    info.Tags = dom.SelectValue('//span[@class="genre"]'):split(',')

    local episodeTitle = dom.SelectValue('//div[contains(@class,"tit_area")]//h3')
    local chapterCount = GetChapterCount()

    if(not isempty(episodeTitle)) then
        info.Title = info.Title .. ' - ' .. episodeTitle
    end

    if(chapterCount > 0) then
        info.ChapterCount = chapterCount
    end

end

function GetChapters()

    if(not url:contains('/list?')) then
        return
    end

    url = SetParameter(url, 'page', '1')
    dom = Dom.New(http.Get(url))

    while true do

        local chapterNodes = dom.SelectElements('//td[contains(@class,"title")]/a')
        local nextPageUrl = dom.SelectValue('//a[@class="next"]/@href'):replace('&amp;', '&')

        chapters.AddRange(chapterNodes)

        if(chapterNodes.Count() <= 0) then
            break
        end

        if(isempty(nextPageUrl)) then
            break
        end

        url = nextPageUrl
        dom = Dom.New(http.Get(url))

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"wt_viewer")]/img/@src'))

end

function GetChapterCount()

    url = SetParameter(url, 'page', '1')
    dom = Dom.New(http.Get(url))

    local latestEpisodeUrl = dom.SelectValue('//td[contains(@class,"title")]/a/@href')
    local latestEpisodeNo = GetParameter(latestEpisodeUrl, 'no')

    if(isnumber(latestEpisodeNo)) then
        return tonumber(latestEpisodeNo)
    else
        return 0
    end

end
