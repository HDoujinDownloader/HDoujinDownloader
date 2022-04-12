function Register()

    module.Name = '漫画DB'
    module.Language = 'chinese'

    module.Domains.Add('manhuadb.com')
    module.Domains.Add('www.manhuadb.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Author = dom.SelectValues('//ul[contains(@class,"creators")]//a')
    info.Tags = dom.SelectValues('//ul[contains(@class,"tags")]//a')
    info.Summary = dom.SelectValue('//p[contains(@class,"comic_story")]')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//ol[contains(@class,"links-of-books")]//a'))

end

function GetPages()

    local imageDataStr = DecodeBase64(dom.SelectValue('//script[contains(text(),"img_data")]')
        :regex("img_data\\s*=\\s*'([^']+)", 1))

    local imageData = Json.New(imageDataStr)
    local imageHost = dom.SelectValue('//div[contains(@class,"vg-r-data")]/@data-host')
    local imagePath = dom.SelectValue('//div[contains(@class,"vg-r-data")]/@data-img_pre')

    for filename in imageData.SelectValues('[*].img') do

        local imageUrl = imageHost .. imagePath .. filename

        pages.Add(imageUrl)

    end

end
