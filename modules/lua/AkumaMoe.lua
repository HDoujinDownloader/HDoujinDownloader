function Register()

    module.Name = 'akuma.moe'
    module.Adult = true
    
    module.Domains.Add('akuma.moe')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Type = dom.SelectValues('//span[contains(text(),"Category")]/following-sibling::span//a')
    info.Language = dom.SelectValues('//span[contains(text(),"Language")]/following-sibling::span//a')
    info.Parody = dom.SelectValues('//span[contains(text(),"Parody")]/following-sibling::span//a')
    info.Characters = dom.SelectValues('//span[contains(text(),"Character")]/following-sibling::span//a')
    info.Circle = dom.SelectValues('//span[contains(text(),"Group")]/following-sibling::span//a')
    info.Artist = dom.SelectValues('//span[contains(text(),"Artist")]/following-sibling::span//a')
    info.Tags = dom.SelectValues('//span[contains(text(),"Male") or contains(text(),"Female") or contains(text(),"Other")]/following-sibling::span//a')
    info.PageCount  = dom.SelectValue('//span[contains(text(),"Pages")]/following-sibling::span')

end

function GetPages()

    -- Go to the reader.

    local readerUrl = dom.SelectValue('//div[@id="read"]//a/@href')

    if(not isempty(readerUrl)) then

        url = readerUrl
        dom = Dom.New(http.Get(readerUrl))

    end

    local galleryId = url:regex('\\/g\\/([^\\/?#]+)', 1)
    local csrfToken = dom.SelectValue('//meta[@name="csrf-token"]/@content')

    http.Headers['accept'] = '*/*'
    http.Headers['x-csrf-token'] = csrfToken
    http.Headers['x-requested-with'] = 'XMLHttpRequest'

    local imagesJson = Json.New(http.Post('//akuma.moe/g/' .. galleryId))
    local imagesScript = dom.SelectValue('//script[contains(text(),"img_prt")]')
    local imagesServer = imagesScript:regex('img_prt\\s*=\\s*"([^"]+)', 1)

    for fileName in imagesJson.SelectValues('[*]') do

        local imageUrl = imagesServer .. '/' .. fileName

        pages.Add(imageUrl)

    end

end
