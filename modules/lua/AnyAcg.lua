function Register()

    module.Name = 'AnyACG'

    module.Domains.Add('bato.to', 'BATO.TO')
    module.Domains.Add('batotoo.com', 'BATO.TO')
    module.Domains.Add('mangaseinen.com', 'mangaseinen.com')
    module.Domains.Add('mangatensei.com', 'MangaTensei.com')
    module.Domains.Add('rawmanga.info', 'raw manga')

end

function GetInfo()

    info.Title = dom.GetElementsByTagName('h3')[0]
    info.AlternativeTitle = dom.SelectValue('//div[contains(@class,"alias-set")]'):split('/')
    info.Language = dom.SelectValue('//span[contains(@class, "flag")]/@class'):regex('flag_(\\w+)', 1)
    info.Author = dom.SelectElements('//b[contains(text(), "Author")]/following-sibling::span/a')
    info.Tags = List.New(tostring(dom.SelectElement('//b[contains(text(), "Genre")]/following-sibling::span')):split('/'))
    info.Status = dom.SelectValue('//b[contains(text(), "Status") or contains(text(), "status")]/following-sibling::span/text()')
    info.Summary = dom.SelectValue('//pre/text()')
    info.DateReleased = dom.SelectValue('//b[contains(text(), "Year of Release")]/following-sibling::span/text()')
    info.ReadingDirection = dom.SelectValue('//b[contains(text(), "Reading direction")]/following-sibling::span/text()')

    if(isempty(info.Summary)) then
        info.Summary = dom.SelectValue('//div[contains(@class,"limit-html")]') -- batotoo.com
    end

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//div[@class="main"]//a[contains(@class,"chapt")]'))

    chapters.Reverse()

end

function GetPages()

    -- While the image filenames are in cleartext, the image server is encrypted.
    -- "batojs" is the obfuscated AES decryption key used to decrypt "server".

    local js = JavaScript.New()

    js.Execute(http.Get('https://cdnjs.cloudflare.com/ajax/libs/crypto-js/4.0.0/crypto-js.min.js'))
    js.Execute(dom.SelectValue('//script[contains(text(),"batojs")]'))

    local server = js.Execute('JSON.parse(CryptoJS.AES.decrypt(server, batojs).toString(CryptoJS.enc.Utf8))')
    local images = Json.New(js.Execute("JSON.stringify(images)"))

    for image in images do
        pages.Add(tostring(server)..tostring(image))
    end

end
