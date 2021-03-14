function Register()

    module.Name = 'ImageVenue'

    module.Domains.Add('imagevenue.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//div[contains(@class,"card-header")]')

end

function GetPages()

    pages.Add(url)

end

function BeforeDownloadPage()

    dom = Dom.New(http.Get(page.Url))

    page.Url = dom.SelectValue('//div[contains(@class,"card-body")]//img/@src')

end
