function Register()

    module.Name = 'M-Hentai'
    module.Language = 'chinese'
    module.Adult = true

    module.Domains.Add('amanmi.com', 'A漫迷')
    module.Domains.Add('m-hentai.net', 'M-Hentai')

end

function GetInfo()

    info.Title = dom.SelectValue('//div[contains(@class,"gallerytitle")]')
    info.OriginalTitle = dom.SelectValue('//div[contains(@class,"gallerysubtitle")]')
    info.Parody = dom.SelectValues('//div[contains(text(),"Parody")]/following-sibling::a')
    info.Tags = dom.SelectValues('//div[contains(text(),"Tag")]/following-sibling::a')
    info.Artist = dom.SelectValues('//div[contains(text(),"Artist")]/following-sibling::a')
    info.Language = dom.SelectValues('//div[contains(text(),"Language")]/following-sibling::a')
    info.Type = dom.SelectValues('//div[contains(text(),"Category")]/following-sibling::a')
   
end

function GetPages()

    local readerUrl = dom.SelectValue('//div[contains(@class,"bookthumbnail")]/a/@href')

    if(not isempty(readerUrl)) then

        url = '/' .. readerUrl
        dom = Dom.New(http.Get(url))

    end

    local imagesScript = dom.SelectValue('//script[contains(text(),"displayimagelist")]')
    local imagesJsonStr = imagesScript:regex("displayimagelist\\s*=\\s*JSON\\.parse\\('([^']+)", 1)
    local imagesJson = Json.New(imagesJsonStr)

    pages.AddRange(imagesJson.SelectValues('[*].image_url'))

end
