function Register()

    module.Name = '999Hentai'
    module.Adult = true

    module.Domains.Add('999hentai.net')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.AlternativeTitle = dom.SelectValue('//div[contains(@class,"h3")]')
    info.Type = dom.SelectValues('//span[contains(text(),"Format")]/following-sibling::a')
    info.Language = dom.SelectValues('//span[contains(text(),"Language")]/following-sibling::a')
    info.Tags = dom.SelectValues('//div[contains(@class,"episode-tags")]//a/text()[1]')

end

function GetPages()

    local json = GetGalleryJson()

    local imagesRoot = GetRoot(dom.SelectValue('//meta[contains(@property,"og:image")]/@content'))
    local imagesPath = json.SelectValue('$..picCdn')

    for fileName in json.SelectValues('$..pics[*].url') do
        
        local imageUrl = imagesRoot .. imagesPath .. '/' .. fileName

        pages.Add(imageUrl)

    end

end

function GetGalleryJson()

    local js = JavaScript.New()

    js.Execute('window = {}')
    js.Execute(dom.SelectValue('//script[contains(text(),"__NUXT__")]'))

    return Json.New(js.Execute('JSON.stringify(window.__NUXT__)'))

end
