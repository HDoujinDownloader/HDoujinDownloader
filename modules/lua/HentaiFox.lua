function Register()

    module.Name = "HentaiFox"
    module.Adult = true

    module.Domains.Add('hentaifox.com')

end


local function GetPageCount()
    return tonumber(dom.SelectValue('//span[contains(@class, "pages")]'):after(':'))
end

function GetInfo()

    if(url:contains('/gallery/')) then

        info.Title = dom.SelectValue('//h1')
        info.Parody = dom.SelectValues('//ul[@class="parodies"]//a/text()[1]')
        info.Characters = dom.SelectValues('//ul[@class="characters"]//a/text()[1]')
        info.Tags = dom.SelectValues('//ul[@class="tags"]//a/text()[1]')
        info.Artist = dom.SelectValues('//ul[@class="artists"]//a/text()[1]')
        info.Circle = dom.SelectValues('//ul[@class="groups"]//a/text()[1]')
        info.Language = dom.SelectValues('//ul[@class="languages"]//a/text()[1]')
        info.Type = dom.SelectValues('//ul[@class="categories"]//a/text()[1]')
        info.PageCount = GetPageCount()

    else

        info.Title = dom.SelectValue('//h1'):beforelast('-')

        for galleryUrl in dom.SelectValues('//h2[contains(@class,"g_title")]/a/@href') do

            Enqueue(galleryUrl)

        end

        info.Ignore = true

    end

end

function GetPages()

    -- Make sure that the URL points to the reader.

    local readOnlineUrl = dom.SelectValue('//a[contains(@class, "g_button")]/@href')

    if(not isempty(readOnlineUrl)) then
        url = readOnlineUrl
    end

    dom = dom.New(http.Get(url))

    local imageDir = dom.SelectValue('//input[@name="image_dir"]/@value')
    local galleryId = dom.SelectValue('//input[@name="gallery_id"]/@value')

    local thumbnailsJsonStr = tostring(dom):regex("var\\s*g_th\\s*=\\s*\\$\\.parseJSON\\('(.+?)'\\);", 1)
    local thumbnailsJson = Json.New(thumbnailsJsonStr)

    for key in thumbnailsJson.Keys do

        local pageNumber = key
        local pageExtension = tostring(thumbnailsJson[key]):split(',').First()

        if(pageExtension == 'p') then
            pageExtension = '.png'
        elseif(pageExtension == 'g') then
            pageExtension = '.gif'
        elseif(pageExtension == 'w') then
            pageExtension = '.webp'
        else
            pageExtension = '.jpg'
        end

        pages.Add(FormatString('//i.{0}/{1}/{2}/{3}{4}', module.Domain, imageDir, galleryId, pageNumber, pageExtension))

    end

end
