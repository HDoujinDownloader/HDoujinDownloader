function Register()

    module.Name = 'Komikast'
    module.Language = 'indonesian'
    module.Adult = false

    module.Domains.Add('komikcast.com')

end

local function CleanTitle(title)

    return tostring(title):before(' Bahasa Indonesia')

end

function GetInfo()
    
    info.Title = CleanTitle(dom.SelectValue('//h1'))
    info.AlternativeTitle = dom.SelectValue('//span[contains(@class,"komik_info-content-native")]')
    info.Tags = dom.SelectValues('//span[contains(@class,"komik_info-content-genre")]/a')
    info.DateReleased = dom.SelectValue('//b[contains(text(),"Released:")]/following-sibling::text()')
    info.Status = dom.SelectValue('//b[contains(text(),"Status:")]/following-sibling::text()')
    info.Author = dom.SelectValue('//b[contains(text(),"Author:")]/following-sibling::text()')
    info.Type = dom.SelectValue('//b[contains(text(),"Type:")]/following-sibling::text()')
    info.Summary = dom.SelectValue('//div[@class="desc"]')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//a[contains(@class,"chapter-link-item")]/@href'))

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"main-reading-area")]/img/@src'))

end
