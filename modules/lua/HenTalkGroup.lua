function Register()

    module.Name = 'HenTalk Group'
    module.Language = 'en'
    module.Adult = true

    module.Domains.Add('fakku.cc')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Artist = dom.SelectValues('//tr[contains(@class,"artists")]//a')
    info.Magazine = dom.SelectValues('//tr[contains(@class,"magazines")]//a')

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"previews")]//a/@href'))

end

function BeforeDownloadPage()

    page.Url = dom.SelectValue('//main//img/@src')

end
