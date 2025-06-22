function Register()
    module.Name = 'AsmHentai'
    module.Adult = true

    module.Domains:Add('asmhentai.com')
end

local function getGalleryId(url)
    return url:regex('\\/g(?:allery)?\\/(\\d+)', 1)
end

local function getPageCount()
    local pageCount = dom.SelectValue('//h3[contains(text(),"Pages:")]'):after(':')

    if isempty(pageCount) then
        pageCount = dom.SelectValue('//*[@id="pages_btn"]//text()'):before('Pages')
    end

    return tonumber(pageCount)
end

local function getThumbnailUrls()
    -- Make request to get session cookies.
    dom = Dom.New(http.Get(url))

    -- Get thumbnail URLs through the API.
    local apiEndpoint = '//' .. module.Domain .. '/inc/thumbs_loader.php'
    local galleryId = getGalleryId(url)
    local loadDir = dom.SelectValue('//input[@id="load_dir"]/@value')
    local totalPages = getPageCount()
    local token = dom.SelectValue('//meta[@name="csrf-token"]/@content')

    -- Galleries with <= 10 pages will not have a "load_dir" value, and we can get all images from the thumbnails.
    -- For galleries that require a login, we can find this value from the reader.
    if isempty(loadDir) and totalPages > 10 then
        url = url:gsub("/g/(%d+)/?", "/gallery/%1/1/")
        dom = Dom.New(http.Get(url))
        loadDir = dom.SelectValue('//input[contains(@id,"image_dir")]/@value')
    end

    if not isempty(loadDir) then
        http.Headers['Accept'] = '*/*'
        http.Headers['X-Requested-With'] = 'XMLHttpRequest'

        http.PostData['_token'] = token
        http.PostData['id'] = galleryId
        http.PostData['dir'] = loadDir
        http.PostData['visible_pages'] = '0'
        http.PostData['t_pages'] = tostring(totalPages)
        http.PostData['type'] = '2'

        local apiResponse = http.Post(apiEndpoint)

        dom = dom.New(apiResponse)
    end

    -- Get the thumbnail URLs directly from the HTML.
    return dom.SelectValues('//div[contains(@class,"preview_thumb")]//img/@data-src')
end

function GetInfo()
    local backToGalleryUrl = dom.SelectValue('//a[contains(@class,"return_btn") or contains(@class,"back_btn")]/@href')

    if(not isempty(backToGalleryUrl)) then
        -- The user added a reader URL.
        -- Navigate to the gallery page instead.
        info.Url = backToGalleryUrl
        dom = Dom.New(http.Get(info.Url))
    end

    info.Title = dom.SelectValue('//h1')
    info.OriginalTitle = dom.SelectValue('//h2')
    info.Artist = dom.SelectValues('//h3[contains(text(),"Artists")]/following-sibling::div//span[contains(@class,"tag")]/text()[1]')
    info.Parody = dom.SelectValues('//h3[contains(text(),"Parodies") or contains(text(),"Parody")]/following-sibling::div//span[contains(@class,"tag")]/text()[1]')
    info.Tags = dom.SelectValues('//h3[contains(text(),"Tags")]/following-sibling::div//span[contains(@class,"tag")]/text()[1]')
    info.Characters = dom.SelectValues('//h3[contains(text(),"Characters")]/following-sibling::div//span[contains(@class,"tag")]/text()[1]')
    info.Language = dom.SelectValues('//h3[contains(text(),"Language")]/following-sibling::div//span[contains(@class,"tag")]/text()[1]')
    info.Type = dom.SelectValues('//h3[contains(text(),"Categories")]/following-sibling::div//span[contains(@class,"tag")]/text()[1]')
    info.PageCount = getPageCount()

    -- Cloudflare's email protection obfuscates anything with an @ symbol (lol).
    -- e.g. https://asmhentai.com/g/231921/
    if(info.Title:contains('__cf_email__')) then
        info.Title = tostring(dom.Title):beforelast(' - ')
    end
end

function GetPages()
    for thumbnailUrl in getThumbnailUrls() do
        local imageUrl = RegexReplace(thumbnailUrl, 't(\\..+?)$', '$1')

        pages.Add(imageUrl)
    end
end
