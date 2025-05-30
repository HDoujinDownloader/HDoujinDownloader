function Register()

    module.Name = 'ManhwaRead'
    module.Language = 'en'
    module.Adult = true

    module.Domains.Add('manhwaread.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//div[contains(@class,"manga-titles")]/h1')
    info.AlternativeTitle = dom.SelectValue('//div[contains(@class,"manga-titles")]/h2'):split('|')
    info.Status = dom.SelectValue('//span[contains(@class,"manga-status__label")]//span[last()]')
    info.Summary = dom.SelectValue('//div[contains(@id,"mangaDesc")]//p')
    info.Publisher = dom.SelectValue('//div[contains(text(),"Publisher:")]/following-sibling::div//a/span[1]')
    info.Author = dom.SelectValue('//div[contains(text(),"Author:")]/following-sibling::div//a/span[1]')
    info.Artist = dom.SelectValue('//div[contains(text(),"Artist:")]/following-sibling::div//a/span[1]')
    info.Tags = dom.SelectValues('//div[contains(text(),"Tags:")]/following-sibling::div//a/span[1]')

end

function GetChapters()

    for chapterNode in dom.SelectElements('//div[contains(@id,"chaptersList")]//a') do

        local chapterTitle = chapterNode.SelectValue('./span[1]')
        local chapterUrl = chapterNode.SelectValue('./@href')

        chapters.Add(chapterUrl, chapterTitle)

    end

end

function GetPages()

    local chapterDataJsonStr = dom.SelectValue('//script[contains(text(),"chapterData")]')
        :regex('chapterData\\s*=\\s*(\\{.+?\\})', 1)
    local chapterDataJson = Json.New(chapterDataJsonStr)
    local dataJson = Json.New(DecodeBase64(chapterDataJson.SelectValue('data')))
    local baseUrl = chapterDataJson.SelectValue('base')

    for pageFileName in dataJson.SelectValues('[*].src') do
        pages.Add(baseUrl .. '/' .. pageFileName)
    end

end
