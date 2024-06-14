function Register()

    module.Name = 'IMHentai'
    module.Adult = true

    module.Domains.Add('comicporn.xxx', 'Comic Porn XXX')
    module.Domains.Add('imhentai.com', 'IMHentai')
    module.Domains.Add('imhentai.xxx', 'IMHentai')

end

local function GetFileExtensionFromKey(key)

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

local function GetImageServerFromGalleryId(galleryId)

    -- The logic that selects an image server is in main.js.
    local imageServer

    if(galleryId > 0 and galleryId <= 274825) then
        imageServer = 'm1'
    elseif(galleryId > 274825 and galleryId <= 403818) then
        imageServer = 'm2'
    elseif(galleryId > 403818 and galleryId <= 527143) then
        imageServer = 'm3'
    elseif(galleryId > 527143 and galleryId <= 632481) then
        imageServer = 'm4'
    elseif(galleryId > 632481 and galleryId <= 816010) then
        imageServer = 'm5'
    elseif(galleryId > 816010 and galleryId <= 970098) then
        imageServer = 'm6'
    elseif(galleryId > 970098 and galleryId <= 1121113) then
        imageServer = 'm7'
    elseif(galleryId > 1121113 and galleryId <= 1259410) then
        imageServer = 'm8'
    else
        imageServer = 'm9'
    end

    return imageServer

end

function GetInfo()

    if(url:contains('/view/')) then
        
        -- Go to the main gallery page.

        local backToGalleryUrl = dom.SelectValue('//a[contains(@class,"return_btn")]/@href')

        if(not isempty(url)) then

            url = backToGalleryUrl
            dom = Dom.New(http.Get(backToGalleryUrl))

        end

    end

    if(url:contains('/gallery/')) then
        
        info.Title = dom.SelectValue('//h1')
        info.OriginalTitle = dom.SelectValue('//p[contains(@class,"subtitle")]')
        info.Parody = dom.SelectValues('//span[contains(text(),"Parodies")]/following-sibling::a/text()[1]')
        info.Characters = dom.SelectValues('//span[contains(text(),"Characters")]/following-sibling::a/text()[1]')
        info.Tags = dom.SelectValues('//span[contains(text(),"Tags")]/following-sibling::a/text()[1]')
        info.Artist = dom.SelectValues('//span[contains(text(),"Artists")]/following-sibling::a/text()[1]')
        info.Circle = dom.SelectValues('//span[contains(text(),"Groups")]/following-sibling::a/text()[1]')
        info.Language = dom.SelectValues('//span[contains(text(),"Languages")]/following-sibling::a/text()[1]')
        info.Type = dom.SelectValues('//span[contains(text(),"Category")]/following-sibling::a/text()[1]')
        info.Url = url

        if(isempty(info.Tags)) then
            info.Tags = dom.SelectValues('//span[contains(text(),"Tags")]/following-sibling::div//a')
        end

        if(isempty(info.Artist)) then
            info.Artist = dom.SelectValues('//span[contains(text(),"Artists")]/following-sibling::div//a')
        end

        if(isempty(info.Language)) then
            info.Language = dom.SelectValues('//span[contains(text(),"Languages")]/following-sibling::div//a')
        end

        if(isempty(info.Type)) then
            info.Type = dom.SelectValues('//span[contains(text(),"Category")]/following-sibling::div//a')
        end

    else

        -- Assume a tag URL was added, and add all galleries to the download queue.

        for galleryUrl in dom.SelectValues('//h2[contains(@class,"gallery_title")]//a/@href') do
            Enqueue(galleryUrl)
        end

        info.Ignore = true

    end

end

function GetPages()

    -- On the main site, "gallery_id" and "u_id" (from the reader) have the same value.
    -- But for some variants, they're different, and we need to access the reader to get the latter.
    
    local readerUrl = dom.SelectValue('//div[contains(@class,"gthumb")]/a/@href')

    local loadDir = dom.SelectValue('//input[@id="load_dir"]/@value')
    local loadId = dom.SelectValue('//input[@id="load_id"]/@value')
    local galleryId = tonumber(dom.SelectValue('//input[@id="gallery_id"]/@value'))

    if(not isempty(readerUrl)) then
        
        url = readerUrl
        dom = Dom.New(http.Get(url))

        loadDir = dom.SelectValue('//input[@id="image_dir"]/@value')
        loadId = dom.SelectValue('//input[@id="gallery_id"]/@value')
        galleryId = tonumber(dom.SelectValue('//input[@id="u_id"]/@value'))

    end

    -- The JSON object has the file names as the key; the value is a 3-tuple starting with a letter that indicates the file type.

    local imagesJson = Json.New(tostring(dom):regex("g_th\\s*=\\s*\\$\\.parseJSON\\('(.+?)'\\)", 1))
    local imageServer = GetImageServerFromGalleryId(galleryId)

    for key in imagesJson.Keys do

        local filename = key..GetFileExtensionFromKey(tostring(imagesJson[key]):split(',').first())
        local imageUrl = FormatString('https://{0}.{1}/{2}/{3}/{4}', imageServer, module.Domain, loadDir, loadId, filename)

        pages.Add(imageUrl)

    end

end
