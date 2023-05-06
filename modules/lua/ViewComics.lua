function Register()

    module.Name = 'ViewComics'
    module.Language = 'en'

    module.Domains.Add('viewcomics.co')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.AlternativeTitle = dom.SelectValue('//td[contains(.,"Alternate Name:")]/following-sibling::td')
    info.DateReleased = dom.SelectValue('//td[contains(.,"Year of Release:")]/following-sibling::td')
    info.Author = dom.SelectValue('//td[contains(.,"Author:")]/following-sibling::td')
    info.Summary = dom.SelectValue('//div[contains(@class,"detail-desc-content")]/p')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//a[contains(@class,"ch-name")]'))

    chapters.Reverse()

end

function GetPages()

    -- Switch to "full" mode to access all images.

    url = url:trim('/') .. '/full'
    dom = Dom.New(http.Get(url))

    pages.AddRange(dom.SelectValues('//div[contains(@class,"chapter-container")]//img/@src'))

end
