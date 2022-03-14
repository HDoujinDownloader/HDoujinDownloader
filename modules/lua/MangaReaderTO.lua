function Register()

    module.Name = 'MangaReader'
    module.Language = 'en'
    module.Adult = false

    module.Domains.Add('mangareader.to')

end

function GetInfo()

    info.Title = dom.SelectValue('//h2[contains(@class,"manga-name")]')
    info.AlternativeTitle = dom.SelectValue('//div[contains(@class,"manga-name-or")]')
    info.Tags = dom.SelectValues('//div[contains(@class,"genres")]/a')
    info.Summary = dom.SelectValue('//div[contains(@class,"description")]')
    info.Type = dom.SelectValue('//span[contains(text(),"Type:")]/following-sibling::a')
    info.Status = dom.SelectValue('//span[contains(text(),"Status:")]/following-sibling::span')
    info.DateReleased = dom.SelectValue('//span[contains(text(),"Published:")]/following-sibling::span')

end

function GetChapters()

    for chapterNode in dom.SelectElements('//div[contains(@class,"chapters-list")]//a') do

        local chapterUrl = chapterNode.SelectValue('@href')
        local chapterTitle = chapterNode.SelectValue('.//span[contains(@class,"name")]')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    local chapterId = dom.SelectValue('//div[@id="wrapper"]/@data-reading-id')
    local quality = 'high'
    local apiEndpoint = '/ajax/image/list/chap/' .. chapterId .. '?mode=vertical&quality=' .. quality .. '&hozPageSize=1'

    http.Headers['accept'] = '*/*'
    http.Headers['x-requested-with'] = 'XMLHttpRequest'

    local json = Json.New(http.Get(apiEndpoint))
    dom = Dom.New(json.SelectValue('html'))

    pages.AddRange(dom.SelectValues('//div[contains(@class,"iv-card")]/@data-url'))

end
