function Register()

    module.Name = 'Doujindesu'
    module.Adult = true

    module.Domains.Add('doujindesu.tv')

end

function GetInfo()

    info.Title = dom.SelectValue('//section[contains(@class,"metadata")]//h1/text()[1]')
    info.AlternativeTitle = dom.SelectValue('//span[contains(@class,"alter")]')
    info.Status = dom.SelectValues('//td[contains(text(),"Status")]/following-sibling::td//a')
    info.Type = dom.SelectValues('//td[contains(text(),"Type")]/following-sibling::td//a')
    info.Author = dom.SelectValues('//td[contains(text(),"Author")]/following-sibling::td//a')
    info.Publisher = dom.SelectValue('//td[contains(text(),"Serialization")]/following-sibling::td')
    info.Tags = dom.SelectValues('//div[contains(@class,"tags")]//a')
    info.Summary = dom.SelectValue('//strong[contains(text(),"Sinopsis")]/following-sibling::text()')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//span[contains(@class,"lchx")]//a'))

    chapters.Reverse()

end

function GetPages()

    local galleryId = dom.SelectValue('//main[contains(@id,"reader")]/@data-id')
    local apiEndpoint = "/themes/ajax/ch.php"

    http.Headers['Accept'] = '*/*'
    http.Headers['X-Requested-With'] = 'XMLHttpRequest'
    http.Headers['Origin'] = GetRoot(url):trim('/')

    http.PostData['id'] = galleryId

    dom = Dom.New(http.Post(apiEndpoint))

    pages.AddRange(dom.SelectValues('//img/@src'))

end
