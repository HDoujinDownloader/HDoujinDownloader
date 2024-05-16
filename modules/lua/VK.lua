function Register()

    module.Name = 'VK'

    module.Domains.Add('vk.com')

end

local function CleanTitle(title)

    return tostring(title)
        :beforelast('&#8211;')
        :beforelast(' | VK')

end

local function GetImageCount()

    return tonumber(dom.SelectValue('(//span[contains(@class,"ui_crumb_count")])[last()]'))

end

local function PrepareHttpHeaders()

    http.Headers['accept'] = '*/*'
    http.Headers['x-requested-with'] = 'XMLHttpRequest'

end

function GetInfo()

    info.Title = CleanTitle(dom.Title)
    info.Summary = dom.SelectValue('//div[contains(@class,"intro_desc")]')

    if(url:contains('/album-') or url:contains('/photos-')) then
        info.PageCount = GetImageCount()
    end

end

function GetChapters()

    if(url:contains('/albums-')) then

        url = StripParameters(url)
        
        local albumsPerPage = 24
        local totalAlbums = tonumber(dom.SelectValue('//span[contains(@class,"ui_crumb_count")]'))
        
        for i = 0, totalAlbums, albumsPerPage do
            
            PrepareHttpHeaders()
    
            http.PostData['al'] = 1
            http.PostData['al_ad'] = 0
            http.PostData['offset'] = i
            http.PostData['part'] = 1
    
            local json = Json.New(http.Post(url))
            local payload = json.SelectValue('payload[1][1]')
    
            dom = dom.New(payload)

            local albumNodes = dom.SelectElements('//a[contains(@data-href,"album-")]')
    
            for j = 0, albumNodes.Count() - 1 do
    
                local albumNode = albumNodes[j]
                local albumUrl = albumNode.SelectValue('@href')
                local albumTitle = albumNode.SelectValue('.//div[contains(@class,"ge_photos_album")]')
        
                chapters.Add(albumUrl, albumTitle)
        
            end

            if(albumNodes.Count() <= 0) then break end
            if(chapters.Count() >= totalAlbums) then break end
    
        end

    end

end

function GetPages()

    url = StripParameters(url)

    local imagesPerPage = 40
    local totalImages = GetImageCount()
    local offset = 0

    local imagesUrlsDict = Dict.New()

    repeat

        local previousImageCount = imagesUrlsDict.Values.Count()

        http.PostData['al'] = 1
        http.PostData['al_ad'] = 0
        http.PostData['offset'] = offset
        http.PostData['part'] = 1

        -- Occasionally the JSON is prepended with "<!--". (Why?)

        local postResponse = http.Post(url):after('<!--')
        local json = Json.New(postResponse)
        local payload = json.SelectValue('payload[1][1]')

        dom = dom.New(payload)

        local imageUrls = dom.SelectValues('//a/@href')

        for imageUrl in imageUrls do
            imagesUrlsDict[imageUrl] = imageUrl
        end

        local newImageCount = imagesUrlsDict.Values.Count() - previousImageCount

        if(imageUrls.Count() <= 0) then break end
        if(pages.Count() >= totalImages) then break end
        if(newImageCount <= 0) then break end

        offset = offset + imagesPerPage
        totalImages = totalImages - newImageCount

    until(totalImages <= 0)

    pages.AddRange(imagesUrlsDict.Values)

    pages.Sort()

end

function BeforeDownloadPage()

    local dataId = page.Url:regex('\\/[a-z]+(-.+?)(?:$|#|\\?)', 1)

    PrepareHttpHeaders()

    http.PostData['act'] = 'show'
    http.PostData['al'] = '1'
    http.PostData['module'] = 'photos'
    http.PostData['photo'] = dataId

    local json = Json.New(http.Post('/al_photos.php?act=show'))
    local imageNode = json.SelectToken('payload[*][*][?(@.id==\'' .. dataId .. '\')]')
    local imageUrl = imageNode.selectValue('w_src')

    if(isempty(imageUrl)) then
        imageUrl = imageNode.selectValue('x_src')
    end

    if(isempty(imageUrl)) then
        imageUrl = imageNode.selectValue('y_src')
    end

    if(isempty(imageUrl)) then
        imageUrl = imageNode.selectValue('z_src')
    end

    page.Url = imageUrl

end
