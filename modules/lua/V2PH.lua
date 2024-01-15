function Register()

    module.Name = 'V2PH'
    module.Type = 'photography'

    module.Domains.Add('v2ph.com')
    module.Domains.Add('v2ph.net')
    module.Domains.Add('www.v2ph.com')
    module.Domains.Add('www.v2ph.net')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.DateReleased = dom.SelectValue('//dt[contains(text(),"Release Date")]/following-sibling::dd[1]')
    info.Characters = dom.SelectValues('//dt[contains(text(),"Album Models")]/following-sibling::dd[1]//a')
    info.Tags = dom.SelectValues('//dt[contains(text(),"Gallery Tags")]/following-sibling::dd[1]//a')
    info.Publisher = dom.SelectValues('//dt[contains(text(),"Graphic Vendor")]/following-sibling::dd[1]//a')
    info.Summary = dom.SelectValue('//div[contains(@class,"album-intro-body")]')
    info.PageCount = dom.SelectValue('//dt[contains(text(),"Photos")]/following-sibling::dd[1]')

end

function GetPages()

    url = StripParameters(url)
    dom = Dom.New(http.Get(url))

    for page in Paginator.New(http, dom, '//a[contains(@class,"page-link") and contains(text(),"Next")]/@href') do
    
        pages.AddRange(page.SelectValues('//div[contains(@class,"album-photo")]//img/@data-src'))
    
    end

end
