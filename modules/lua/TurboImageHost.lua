function Register()

    module.Name = 'TurboImageHost'

    module.Domains.Add('turboimagehost.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')

end

function GetPages()

    pages.Add(url)

end

function BeforeDownloadPage()

    dom = Dom.New(http.Get(page.Url))

    page.Url = dom.SelectValue('//img[contains(@class,"uImage")]/@src')

end
