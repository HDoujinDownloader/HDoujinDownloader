function Register()

    module.Name = 'ReadComicOnline'

    module.Domains.Add('readcomiconline.li')
    module.Domains.Add('readcomiconline.com')
    module.Domains.Add('readcomiconline.me')
    module.Domains.Add('readcomiconline.to')

end

function GetInfo()

    info.Title = dom.SelectValue('//a[contains(@class,"bigChar")]')
    info.Tags = dom.SelectValues('//span[contains(text(),"Genres:")]/following-sibling::a')
    info.Publisher = dom.SelectValues('//span[contains(text(),"Publisher:")]/following-sibling::a')
    info.Author = dom.SelectValues('//span[contains(text(),"Writer:")]/following-sibling::a')
    info.Artist = dom.SelectValues('//span[contains(text(),"Artist:")]/following-sibling::a')
    info.DateReleased = dom.SelectValue('//span[contains(text(),"Publication date:")]/following-sibling::text()')
    info.Status = dom.SelectValue('//span[contains(text(),"Status")]/following-sibling::text()')
    info.Summary = dom.SelectValue('//p[span[contains(text(),"Summary:")]]/following-sibling::p')

    -- reader

    if(isempty(info.Title)) then
        info.Title = dom.Title:before('- Read')
    end

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//table[contains(@class,"listing")]//td/a'))

end

function GetPages()

    url = SetParameter(url, 'readType', 1)

    dom = Dom.New(http.Get(url))

    for imageUrl in tostring(dom):regexmany('lstImages\\.push\\("([^"]+)"', 1) do
        pages.Add(imageUrl)
    end

    pages.Referer = ''

end
