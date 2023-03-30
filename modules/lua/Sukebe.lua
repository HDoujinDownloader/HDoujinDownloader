function Register()

    module.Name = 'Sukebe'
    module.Adult = true

    module.Domains.Add('sukebe.moe')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.OriginalTitle = dom.SelectValue('//h2')
    info.Language = dom.SelectValues('//div[strong[contains(text(),"Language")]]//a/span[1]')
    info.Artist = dom.SelectValues('//div[strong[contains(text(),"Artist")]]//a/span[1]')
    info.Tags = dom.SelectValues('//div[strong[contains(text(),"Male") or contains(text(),"Female") or contains(text(),"Mixed") or contains(text(),"Other")]]//a/span[1]')
    info.PageCount = dom.SelectValue('//div[strong[contains(text(),"Pages")]]//span'):regex('(^\\d+)', 1)

end

function GetPages()

    -- Go to the reader.

    local readerUrl = dom.SelectValue('//a[@id="read"]/@href')

    if(not isempty(readerUrl)) then

        url = readerUrl
        dom = Dom.New(http.Get(readerUrl))

    end

    local metadataScript = dom.SelectValue('//script[contains(text(),"window.metadata")]')
    local imagesJson = Json.New(metadataScript:regex('original:\\s*(\\[.+?\\])', 1))
    local dataId = dom.SelectValue('//main/@data-id')
    local dataKey = dom.SelectValue('//main/@data-key')

    for fileName in imagesJson.SelectValues('[*].n') do

        local imageUrl = '//data.' .. module.Domain .. '/original/' .. dataId .. '/' .. dataKey .. '/' .. fileName

        pages.Add(imageUrl)

    end

end
