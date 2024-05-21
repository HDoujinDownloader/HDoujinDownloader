function Register()

    module.Name = 'MangaThailand'
    module.Language = 'thai'

    module.Domains.Add('mangathailand.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.AlternativeTitle = dom.SelectValue('(//h1)[2]')
    info.Summary = dom.SelectValues('//div[contains(@class,"theme-post-content")]//p'):join('\n\n')
    info.Tags = dom.SelectValues('//span[contains(@class,"info__terms-list")]/a')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('(//div[contains(@class,"elementor-grid-1")])[1]//a'))

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//img[contains(@class,"manga-img")]/@data-src'))

end
