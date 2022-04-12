function Register()

    module.Name = 'MangaYeh'
    module.Language = 'en'

    module.Domains.Add('mangayeh.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.AlternativeTitle = dom.SelectValue('//td[contains(text(),"Alt names:")]/following-sibling::td')
    info.Author = dom.SelectValues('//td[contains(text(),"Author:")]/following-sibling::*//a')
    info.Artist = dom.SelectValues('//td[contains(text(),"Artist:")]/following-sibling::*//a')
    info.Tags = dom.SelectValues('//span[contains(@class,"tag")]')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//div[@id="chapterList"]//td[1]/a'))

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//img[contains(@class,"lzl")]/@data-src'))

end
