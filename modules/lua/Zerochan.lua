function Register() -- required

    module.Name = 'Zerochan'
    module.Domains.Add('zerochan.net')
    module.Type = 'Artist CG'
    module.Strict = false -- We can get a page count that is less than the actual number of images

end

function GetInfo() -- required

    if(GetDepth(url) > 0) then -- ignore the homepage
        
        local dom = Dom.New(doc)

        info.Title = CleanTitle(dom.Title)
        info.PageCount = tonumber(dom.GetElementById("parents-listing").InnerText:regex('^[\\d,]+')) or 0 -- 0 denotes unknown page count
        info.Tags = dom.SelectElements('//*[@id="parents-listing"]/a')
        info.Summary = dom.SelectElement('//*[@id="menu"]/p[4]')
        info.Url = StripParameters(url) -- Ensures that we are on the first pagination page
        
        if(List.New(info.Tags).Contains('mangaka')) then
            info.Artist = info.Title             
        end

    end

end

function GetPages() -- required

    url = StripParameters(url)

    local dom = Dom.New(http.Get(url))
    local paginationCount = tonumber(dom.SelectValue('//*[@class="pagination"]/text()'):regex('([\\d,]+)\\s*$', 1)) or 0

    for i = 2, paginationCount + 1 do
    
        -- Since we can't get the image URLs directly from here (at least not for GIFs), we'll get the viewer URLs and get the direct image URL later.
        -- Note that we won't be able to access 18+ images if we're not signed in, and their links will be replaced with "/register" links.

        local viewerUrls = dom.SelectValues('//ul[contains(@id, "thumbs")]/li/a[@tabindex]/@href') -- check for tabindex attribute to ignore members-only links

        -- Didn't get anything? Something must be wrong (or all images on this page are members-only?), so don't bother continuing.
        
        if(viewerUrls.Count() <= 0) then
            break
        end

        pages.AddRange(viewerUrls)

        -- Go to the next pagination page.
        -- Note that instead of setting the "p" parameter, we get the parameter directly from the page. This is because it changes to an "o" parameter after a certain depth.

        local nextPaginationParameter = dom.SelectValue('//a[@rel="next"]/@href')
        
        -- If there are no more pages to visit, stop here.

        if(nextPaginationParameter:empty()) then
            break
        end

        local nextPaginationUrl = url .. nextPaginationParameter

        dom = Dom.New(http.Get(nextPaginationUrl))

    end

    -- Reverse the image list so that older images are listed first.
   
    pages.Reverse()

end

function BeforeDownloadPage() -- required
    
    local doc = http.Get(page.Url)

    -- We'll set the full-size image as the primary URL, and then add the thumbnail image as a backup URL.
    -- This is because it's possible that the full-size image will 404. You take what you can get I guess.
    -- Ex: https://www.zerochan.net/13043

    page.Url = doc:between('"contentUrl": "', '"')
    page.BackupUrls.Add(doc:between('"thumbnail": "', '"'))

end

function Login() -- required

    -- A login is required to access 18+ content.

    if(http.Cookies.Empty()) then
    
        http.Referer = 'https://www.zerochan.net/'
    
        http.PostData.Add('ref', '/')
        http.PostData.Add('name', username)
        http.PostData.Add('password', password)
        http.PostData.Add('login', 'Login')

        local response = http.PostResponse('https://www.zerochan.net/login')
    
        if(not tostring(response):contains('>Logged in as <')) then
            Fail(Error.LoginFailed)
        end
    
        global.SetCookies(response.Cookies)
    
    end

end

function CleanTitle(title)

    return tostring(title)
        :beforelast(' - ')
        :beforelast('|')
        :trim()

end
