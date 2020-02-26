function Register()

    module.Name = "HentaiFox"
    module.Adult = true

    module.Domains.Add('hentaifox.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Parody = dom.SelectValues('//ul[@class="parodies"]//a/text()[1]')
    info.Tags = dom.SelectValues('//ul[@class="tags"]//a/text()[1]')
    info.Artist = dom.SelectValues('//ul[@class="artists"]//a/text()[1]')
    info.Circle = dom.SelectValues('//ul[@class="groups"]//a/text()[1]')
    info.Language = dom.SelectValues('//ul[@class="languages"]//a/text()[1]')
    info.Type = dom.SelectValues('//ul[@class="categories"]//a/text()[1]')
    info.PageCount = GetPageCount()

end

function GetPages()

    -- Make sure that the URL points to the reader.

    local readOnlineUrl = dom.SelectValue('//a[contains(@class, "g_button")]/@href')

    if(not isempty(readOnlineUrl)) then
        url = readOnlineUrl
    end

    dom = dom.New(http.Get(url))

    local pageCount = GetPageCount()
    local imageDir = dom.SelectValue('//input[@name="image_dir"]/@value')
    local galleryId = dom.SelectValue('//input[@name="gallery_id"]/@value')

    for i = 1, pageCount do

        pages.Add(FormatString('//i.{0}/{1}/{2}/{3}.jpg', module.Domain, imageDir, galleryId, i))

    end

end

function GetPageCount()

    return tonumber(dom.SelectValue('//span[contains(@class, "pages")]'):after(':'))

end
