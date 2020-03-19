function Register() 

    module.Name = 'HGameCg'
    module.Type = 'Artist CG'
    module.Language = 'Japanese'
    module.Adult = true

    module.Domains.Add('hgamecg.com', 'HGAMECG.COM')


end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Circle = info.Title:regex('^\\[(.+?)\\]', 1)
    info.PageCount = doc:regex('-(\\d+)\\.html', 1) -- (image URLs have the total number of images at the end)
   
    -- Make sure we're on the first page of the gallery.

    info.Url = RegexReplace(info.Url, '\\/page-\\d+\\-', '/page-1-')

end

function GetPages()

    -- Galleries are paginated into groups of 25 images.

    local lastPaginationUrl = ''
    local paginationUrls = List.New()

    repeat

        paginationUrls.Add(lastPaginationUrl)

        -- Convert the thumbnail URLs into full image URLs.

        local thumbnailUrls = dom.SelectValues('//div[contains(@class, "image")]//img/@src')

        for thumbnailUrl in thumbnailUrls do

            local fullImageUrl = thumbnailUrl:replace('//thumbnail.', '//galleries.')
    
            pages.Add(fullImageUrl)
    
        end

        -- Get the URL of the next page.

        lastPaginationUrl = dom.SelectValue('//a[contains(., "Next Page")]/@href')

        if(not isempty(lastPaginationUrl)) then
            dom = dom.New(http.Get(lastPaginationUrl))    
        end

    until(isempty(lastPaginationUrl) or paginationUrls.Contains(lastPaginationUrl) or pages.Count() <= 0)

end
