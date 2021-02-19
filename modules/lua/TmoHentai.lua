function Register()

    module.Name = 'TMOHentai'
    module.Adult = true

    module.Domains.Add('tmohentai.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h3')
    info.Type = dom.SelectValue('//div[contains(@class,"content-type")]')
    info.Artist = dom.SelectValues('//li[contains(.,"Artists")]/following-sibling::li[1]/a')
    info.Tags = dom.SelectValues('//li[contains(.,"Tags")]/following-sibling::li/a')
    info.Language = dom.SelectValue('//li[contains(.,"Language")]/following-sibling::li/a'):after(';')
    info.PageCount = dom.SelectValue('//img[contains(@alt,"Image")]/@alt'):regex('\\d+\\/(\\d+)', 1)

    if(url:contains('/reader/')) then
        info.Title = dom.SelectValue('//h1')
    end

end

function GetPages()

    local readerUrl = dom.SelectValue('//div[contains(@class,"pull-right")]//a/@href')
    
    if(isempty(readerUrl)) then -- Already have reader URL
        readerUrl = url
    end

    readerUrl = RegexReplace(readerUrl, '\\/paginated\\/.+?$', '/cascade/')

    dom = Dom.New(http.Get(readerUrl))

    pages.AddRange(dom.SelectValues('//img[contains(@class,"content-image")]/@data-original'))

    if(isempty(pages)) then
        pages.AddRange(dom.SelectValues('//img[contains(@class,"content-image")]/@src'))
    end

end
