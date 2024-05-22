function Register()

    module.Name = 'RedGIFs'
    module.Adult = true

    module.Domains.Add('redgifs.com')

    module.Strict = false

end

function GetInfo()

    info.Title = tostring(dom.Title):beforelast('|')
    info.PageCount = 0
    
end

function GetPages()

    local searchTerms = url:regex('browse\\/(.+?)(?:$|[\\/?#])', 1)
    local imagesPerRequest = 300
    local offset = 0
    local apiUrl = 'https://api.'..module.Domain..'/v1/gfycats/search?search_text='..searchTerms..'&count='..imagesPerRequest..'&start='..offset

    for i = 0, 100 do -- Should be enough for most queries?

        -- Get the next set of images from the API.

        local json = Json.New(http.Get(apiUrl))

        local mp4Urls = json.SelectValues('gfycats[*].mp4Url')
        --local gifUrls = json.SelectValues('gfycats[*].gifUrl')

        pages.AddRange(mp4Urls)

        -- If we didn't get anymore images, exit the loop.

        if(mp4Urls.Count() <= 0) then break end
        
        -- Update the API url to get the next set of images.

        offset = offset + imagesPerRequest

        apiUrl = SetParameter(apiUrl, 'start', offset)

    end

    -- Unescape all page URLs.

    for page in pages do
        page.Url = page.Url:replace('\\u002F', '/') -- Unescape(page.Url)
    end
    
end
