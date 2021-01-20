function Register()

    module.Name = 'Rule 34 Comics'
    module.Language = 'English'
    module.Adult = true

    module.Domains.Add('r34comics.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//div[contains(@class,"navbar-brand")]/a[last()]')
    info.Parody = dom.SelectValue('//div[contains(@class,"navbar-brand")]/a[2]')

end

function GetChapters()

    for page in Paginator.New(http, dom, '//a[@rel="next"]/@href') do
    
        chapters.AddRange(page.SelectElements('//div[contains(@class,"caption")]//a'))
    
    end

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[@id="photoSwipeData"]/a/@data-src-xlarge'))

end
