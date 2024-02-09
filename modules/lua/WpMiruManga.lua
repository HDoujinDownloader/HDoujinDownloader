-- "Miru-Manga" is a WordPress theme based on the "Underscores" theme.

function Register()

    module.Name = 'miru-manga'
    module.Language = 'thai'
    
    module.Domains.Add('toonsmanga.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.AlternativeTitle = dom.SelectValue('//h1/following-sibling::div//p')
    info.Status = dom.SelectValue('//td[contains(text(),"สถานะ:")]/following-sibling::td//a')
    info.Tags = dom.SelectValue('//a[contains(@rel,"category tag")]')
    info.Type = dom.SelectValue('//td[contains(text(),"Genre:")]/following-sibling::td//a')
    info.Summary = dom.SelectValue('//h2/following-sibling::p')

end

function GetChapters()

    for chapterNode in dom.SelectElements('//div[contains(@id,"ep-list")]//a') do

        local chapterUrl = chapterNode.SelectValue('./@href')
        local chapterTitle = chapterNode.SelectValue('.//h4')

        chapters.Add(chapterUrl, chapterTitle)

    end
    
    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//main//img/@data-lazy-src'))

end
