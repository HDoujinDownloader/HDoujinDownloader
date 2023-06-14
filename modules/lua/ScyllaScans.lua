function Register()

    module.Name = 'Scylla Scans'
    module.Language = 'English'
    module.Adult = false

    module.Domains.Add('scyllascans.org')

end

function GetInfo()

    info.Title = dom.SelectValue('//h4')
    info.Summary = dom.SelectValue('//div[contains(@class,"Description")]')
    info.Tags = dom.SelectValues('//div[contains(@class,"Info__Genres")]/span')
    info.Status = dom.SelectValue('//div[contains(text(),"Status")]/parent::div/following-sibling::div/div')
    info.Type = dom.SelectValue('//div[contains(text(),"Type")]/parent::div/following-sibling::div/div')
    info.Scanlator = module.Name

end

function GetChapters()

    for chapterNode in dom.SelectElements('//a[contains(@class,"Chapter__Chapter")]') do

        local chapterUrl = chapterNode.SelectValue('@href')
        local chapterTitle = chapterNode.SelectValue('div/p[contains(@class,"ChapterTitle-sc")]')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    for pageNode in dom.SelectElements('//div[contains(@class,"ImagesList__ImageList")]/div/span') do

        local pageData = pageNode.SelectValue('@style')

        local pageUrl = pageData:regex('url\\((.+?)\\?.*\\);', 1)

        pages.Add(pageUrl)

    end

end