function Register()

    module.Name = 'MangaBTT'
    module.Language = 'en'
    
    module.Domains.Add('mangabtt.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Tags = dom.SelectValues('//li[contains(@class,"kind row")]//a')
    info.Author = dom.SelectValues('//li[contains(@class,"author")]//a')
    info.Status = dom.SelectValue('//li[contains(@class,"status")]//p[last()]')
    info.Summary = dom.SelectValue('//p[@id="summary"]')

end

function GetChapters()

    local storyId = dom.SelectValue('//input[@id="storyID"]/@value')

    http.Headers['accept'] = '*/*'
    http.Headers['x-requested-with'] = 'XMLHttpRequest'

    http.PostData['StoryID'] = storyId

    dom = Dom.New(http.Post('/Story/ListChapterByStoryID'))

    chapters.AddRange(dom.SelectElements('//a[@data-id]'))

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@id,"page_")]//img[last()]/@src'))

end
