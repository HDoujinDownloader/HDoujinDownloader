function Register()

    module.Name = 'Reaper Scans'
    module.Language = 'English'
    module.Adult = false

    module.Domains.Add('reaperscans.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Summary = dom.SelectValue('//div[contains(@class,"description-summary")]//p')
    info.AlternativeTitle = dom.SelectValue('//div[h5[contains(text(),"Alternative")]]/following-sibling::div')
    info.Author = dom.SelectValues('//div[contains(@class,"author-content")]/a')
    info.Artist = dom.SelectValues('//div[contains(@class,"artist-content")]/a')
    info.Tags = dom.SelectValues('//div[contains(@class,"genres-content")]/a')
    info.Type = dom.SelectValue('//div[h5[contains(text(),"Type")]]/following-sibling::div')
    info.DateReleased = dom.SelectValue('//div[h5[contains(text(),"Release")]]/following-sibling::div/a')
    info.Status = dom.SelectValue('//div[h5[contains(text(),"Status")]]/following-sibling::div')

end

function GetChapters()

    for chapterNode in dom.SelectElements('//div[contains(@class,"chapter-link")]') do

        local chapterUrl = chapterNode.SelectValue('a/@href')
        local chapterTitle = chapterNode.SelectValue('a/p')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//img[contains(@id,"image-")]/@data-src'))

end
