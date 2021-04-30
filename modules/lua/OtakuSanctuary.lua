function Register()

    module.Name = 'Otaku Sanctuary'

    module.Domains.Add('otakusan.net')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Tags = dom.SelectValue('//div[contains(@class,"genres")]/a')
    info.Summary = dom.SelectValue('//p[contains(@class,"summary")]')
    info.AlternativeTitle = dom.SelectValue('//tr[th[contains(text(),"Other Name")]]/following-sibling::tr'):split(';')
    info.Translator = dom.SelectValue('//tr[th[contains(text(),"Translator Name")]]/td')
    info.Type = dom.SelectValue('//tr[th[contains(text(),"Category")]]/td')
    info.Author = dom.SelectValue('//tr[th[contains(text(),"Author")]]/td/a')
    info.Status = dom.SelectValue('//tr[th[contains(text(),"Status")]]/td')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//td[contains(@class,"read-chapter")]/a'))

    chapters.Reverse()

end

function GetPages()

    -- Send a GET request to make sure that we have session cookies (required).

    http.Get(url)

    http.Referer = url
    http.Headers['accept'] = 'application/json, text/javascript, */*; q=0.01'
    http.Headers['content-type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
    http.Headers['origin'] = 'https://'..module.Domain
    http.Headers['x-requested-with'] = 'XMLHttpRequest'

    http.PostData['chapId'] = GetChapterId()

    local json = Json.New(http.Post('/Manga/UpdateView'))

    pages.AddRange(Json.New(json.SelectValue('view')).SelectValues('[*]'))

end

function GetChapterId()

    return url:regex('\\/chapter\\/(.+?)\\/', 1)

end
