function Register()

    module.Name = 'AnyACG (V2)'

end

function GetInfo()

    info.Title = dom.GetElementsByTagName('h3')[0]
    info.AlternativeTitle = dom.SelectValue('//div[contains(@class,"alias-set")]'):split('/')
    info.Language = dom.SelectValue('//span[contains(@class, "flag")]/@class'):regex('flag_(\\w+)', 1)
    info.Author = dom.SelectElements('//b[contains(text(), "Author")]/following-sibling::span/a')
    info.Tags = List.New(tostring(dom.SelectElement('//b[contains(text(), "Genre")]/following-sibling::span')):split('/'))
    info.Status = dom.SelectValue('//b[contains(text(), "Status") or contains(text(), "status") or contains(text(), "Original work")]/following-sibling::span/text()')
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
    js.Execute(dom.SelectValue('//script[contains(text(),"batoWord")]'))

    -- The image list may be in the "imgHttpLis" or "imgHttps" variable.

    js.Execute('var imgHttpLis = imgHttpLis || imgHttps')

    local imageKeys = Json.New(js.Execute('CryptoJS.AES.decrypt(batoWord, batoPass).toString(CryptoJS.enc.Utf8)'))
    local images = Json.New(js.Execute("JSON.stringify(imgHttpLis)"))

    for i = 0, imageKeys.Count() - 1 do

        local imageUrl = tostring(images[i]) .. '?' .. tostring(imageKeys[i])

        pages.Add(imageUrl)

    end

end
