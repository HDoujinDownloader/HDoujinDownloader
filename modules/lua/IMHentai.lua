function Register()

    module.Name = 'IMHentai'
    module.Adult = true

    module.Domains.Add('imhentai.com', 'IMHentai')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Parody = dom.SelectValues('//span[contains(text(),"Parodies")]/following-sibling::a/text()[1]')
    info.Characters = dom.SelectValues('//span[contains(text(),"Characters")]/following-sibling::a/text()[1]')
    info.Tags = dom.SelectValues('//span[contains(text(),"Tags")]/following-sibling::a/text()[1]')
    info.Artist = dom.SelectValues('//span[contains(text(),"Artists")]/following-sibling::a/text()[1]')
    info.Circle = dom.SelectValues('//span[contains(text(),"Groups")]/following-sibling::a/text()[1]')
    info.Language = dom.SelectValues('//span[contains(text(),"Languages")]/following-sibling::a/text()[1]')
    info.Type = dom.SelectValues('//span[contains(text(),"Category")]/following-sibling::a/text()[1]')

end

function GetPages()

    local loadDir = dom.SelectValue('//input[@id="load_dir"]/@value')
    local loadId = dom.SelectValue('//input[@id="load_id"]/@value')
    local galleryId = tonumber(dom.SelectValue('//input[@id="gallery_id"]/@value'))

    -- The JSON object has the filenames as the key; the value is a 3-tuple starting with a letter that indicates the file type.

    local imagesJson = Json.New(tostring(dom):regex("g_th\\s*=\\s*\\$\\.parseJSON\\('(.+?)'\\)", 1))

    -- The logic that selects an image server is in main.js.
    
    local imageServer = 'm5'

    if(galleryId > 0 and galleryId <= 274825) then
        imageServer = 'm1'
    elseif(galleryId > 274825 and galleryId <= 403818) then
        imageServer = 'm2'
    elseif(galleryId > 403818 and galleryId <= 527143) then
        imageServer = 'm3'
    elseif(galleryId > 527143 and galleryId <= 632481) then
        imageServer = 'm4'
    elseif(galleryId > 632481) then
        imageServer = 'm5'
    end

    for key in imagesJson.Keys do

        local filename = key..GetFileExtension(tostring(imagesJson[key]):split(',').first())
        local imageUrl = FormatString('https://{0}.{1}/{2}/{3}/{4}', imageServer, module.Domain, loadDir, loadId, filename)

        pages.Add(imageUrl)

    end

end

function GetFileExtension(key)

    if(key == 'j') then 
        return '.jpg'
    elseif(key == 'p') then 
        return '.png'
    elseif(key == 'b') then 
        return '.bmp'
    elseif(key == 'g') then 
        return '.gif'
    else
        return '.jpg' -- default to .jpg
    end

end
