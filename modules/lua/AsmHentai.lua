function Register()

    module.Name = 'AsmHentai'
    module.Adult = true
    
    module.Domains.Add('asmhentai.com')

end

function GetInfo()

    if(url:contains('/gallery/')) then

        -- The user added a reader URL.
        -- Navigate to the gallery page instead.

        url = GetRoot(url)..'/g/'..GetGalleryId(url)..'/'
        dom = Dom.New(http.Get(url))

    end

    info.Title = dom.SelectValue('//h1')
    info.OriginalTitle = dom.SelectValue('//h2')
    info.Artist = dom.SelectValues('//h3[contains(text(),"Artists")]/following-sibling::div//span[contains(@class,"tag")]/text()[1]')
    info.Parody = dom.SelectValues('//h3[contains(text(),"Parodies") or contains(text(),"Parody")]/following-sibling::div//span[contains(@class,"tag")]/text()[1]')
    info.Tags = dom.SelectValues('//h3[contains(text(),"Tags")]/following-sibling::div//span[contains(@class,"tag")]/text()[1]')
    info.Characters = dom.SelectValues('//h3[contains(text(),"Characters")]/following-sibling::div//span[contains(@class,"tag")]/text()[1]')
    info.Language = dom.SelectValues('//h3[contains(text(),"Language")]/following-sibling::div//span[contains(@class,"tag")]/text()[1]')
    info.Type = dom.SelectValues('//h3[contains(text(),"Categories")]/following-sibling::div//span[contains(@class,"tag")]/text()[1]')
    info.PageCount = GetPageCount()

    -- Cloudflare's email protection obfuscates anything with an @ symbol (lol).
    -- e.g. https://asmhentai.com/g/231921/

    if(info.Title:contains('__cf_email__')) then
        info.Title = tostring(dom.Title):beforelast(' - ')
    end

end

function GetPages()

    -- Make request to get session cookies.

    dom = dom.New(http.Get(url))

    -- Get thumbnail URLs through the API.

    local apiEndpoint = '//' .. module.Domain .. '/inc/thumbs_loader.php'
    local galleryId = GetGalleryId(url)
    local dir = dom.SelectValue('//input[@id="load_dir"]/@value')
    local totalPages = GetPageCount()
    local token = dom.SelectValue('//meta[@name="csrf-token"]/@content')

    -- Galleries with < 10 pages will not have a "load_dir" value, so we can just get the thumbnails directly.

    if(not isempty(dir)) then

        http.Headers['Accept'] = '*/*'
        http.Headers['X-Requested-With'] = 'XMLHttpRequest'
    
        http.PostData['_token'] = token
        http.PostData['id'] = galleryId
        http.PostData['dir'] = dir
        http.PostData['visible_pages'] = '0'
        http.PostData['t_pages'] = tostring(totalPages)
        http.PostData['type'] = '2'

        local apiResponse = http.Post(apiEndpoint)

        dom = dom.New(apiResponse)

    end

    for thumbnailUrl in dom.SelectValues('//div[contains(@class,"preview_thumb")]//img/@data-src') do

        local imageUrl = thumbnailUrl:replace('t.', '.')

        pages.Add(imageUrl)

    end

end

function GetGalleryId(url)

    return url:regex('\\/g(?:allery)?\\/(\\d+)', 1)

end

function GetPageCount()

    return dom.SelectValue('//h3[contains(text(),"Pages:")]'):after(':')

end
