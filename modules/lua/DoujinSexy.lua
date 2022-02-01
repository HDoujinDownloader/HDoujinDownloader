function Register()

    module.Name = 'Doujin.sexy'
    module.Adult = true

    module.Domains.Add('doujin.sexy')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Parody = dom.SelectValues('//a[contains(@class,"tag-link") and contains(@href, "/parody/")]')
    info.Tags = dom.SelectValues('//a[contains(@class,"tag-link") and contains(@href, "/tag/")]')
    info.Characters = dom.SelectValues('//a[contains(@class,"tag-link") and contains(@href, "/character/")]')
    info.Artist = dom.SelectValues('//a[contains(@class,"tag-link") and contains(@href, "/artist/")]')
    info.Language = dom.SelectValues('//a[contains(@class,"tag-link") and contains(@href, "/language/")]')
    info.PageCount = dom.SelectValues('//b[contains(.,"Pages:")]/following-sibling::text()'):join('')

end

function GetPages()

    url = RegexReplace(url, '\\/(?:read\\/\\d*)?$|$', '/read/1')
    dom = Dom.New(http.Get(url))

    local js = JavaScript.New()

    js.Execute('window = {}')
    js.Execute(dom.SelectValue('//script[contains(.,"__SERVER_APP_STATE__ ")]'))

    local json = js.GetObject('window.__SERVER_APP_STATE__').ToJson()
    pages.AddRange(json.SelectValues('initialData.data.pages[*].sizes.full'))

end
