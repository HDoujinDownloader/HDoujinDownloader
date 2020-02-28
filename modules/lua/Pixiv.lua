function Register()

    module.Name = 'Pixiv'
    module.Domain = 'pixiv.net'
    module.Type = 'Artist CG'
    module.Strict = false -- Because artworks can be made up of multiple images, we'll often have more images than expected

end

function GetInfo()

    if(url:contains('/users/')) then

        -- Added user gallery.

        local json = GetUserJson(url)

        VerifyApiResponse(json)

        info.Artist = json.SelectValue('user.name')
        info.Summary = json.SelectValue('user.comment')

        if(url:contains('/manga')) then

            -- Added "manga" tab.
            -- Treat each manga as its own chapter.

            info.Title = info.Artist..'\'s manga'
            info.ChapterCount = json.SelectValue('profile.total_manga')

        else

            -- Added "illustrations" tab.

            info.Title = info.Artist..'\'s illustrations'
            info.PageCount = json.SelectValue('profile.total_illusts')

        end

    elseif(url:contains('/artworks/')) then

        -- Added single artwork.

        local json = GetIllustrationJson(url)

        VerifyApiResponse(json)

        info.Title = json.SelectValue('illust.title')
        info.Artist = json.SelectValue('illust.user.name')
        info.Summary = json.SelectValue('illust.caption')
        info.Tags = json.SelectValues('illust.tags[*].name')
        info.DateReleased = json.SelectValue('illust.create_date')
        info.PageCount = json.SelectValue('illust.page_count')
        info.Adult = List.New(info.Tags).Contains('R-18')

    end

end

function GetPages()

    if(url:contains('/users/')) then

        -- Added user gallery.

        local type = 'illust'
        local offset = 0
        local json = GetIllustrationsJson(url, type, offset)

        VerifyApiResponse(json)

        -- We can't get all images in one go; we can only get 30 images at a time.
        -- Keep going until we don't get anymore images (up to an offset of 5000, which is the limit enforced by the API).

        while json['illusts'].Count() > 0 and offset < 5000 do

            for artwork in json['illusts'] do
      
                local singlePage = artwork.SelectValue('meta_single_page.original_image_url')
                local metaPages = artwork.SelectValues('meta_pages[*].image_urls.original')

                if(not isempty(singlePage)) then
                    pages.Add(singlePage)
                end
        
                if(not isempty(metaPages)) then

                    metaPages.Reverse() -- We reverse the page list later; this will make sure the pages are in the correct order.

                    pages.AddRange(metaPages)

                end

            end

            offset = offset + json['illusts'].Count()
            
            if(offset < 5000) then

                json = GetIllustrationsJson(url, type, offset)

            end

        end

        -- Reverse the image list so that oldest images are listed first.

        pages.Reverse()

    elseif(url:contains('/artworks/')) then

        -- Added single artwork.

        local json = GetIllustrationJson(url)

        VerifyApiResponse(json)

        -- Only one of these queries will produce results, so it's fine to add both.

        local singlePage = json.SelectValue('illust.meta_single_page.original_image_url')
        local metaPages = json.SelectValues('illust.meta_pages[*].image_urls.original')

        if(not isempty(singlePage)) then
            pages.Add(singlePage)
        end

        if(not isempty(metaPages)) then
            pages.AddRange(metaPages)
        end

    end

end

function GetChapters()

    -- If we're here, the user added an artist's "manga" tab.
    -- We'll treat each manga as a separate chapter.
    -- Keep going until we don't get anymore manga (up to an offset of 5000, which is the limit enforced by the API).

    local type = 'manga'
    local offset = 0
    local json = GetIllustrationsJson(url, type, offset)

    while json['illusts'].Count() > 0 and offset < 5000 do

        for artwork in json['illusts'] do

            local id = tostring(artwork['id'])
            local title = tostring(artwork['title'])

            chapters.Add('/artworks/'..id, title)


        end

        offset = offset + json['illusts'].Count()
        
        if(offset < 5000) then

            json = GetIllustrationsJson(url, type, offset)

        end

    end

    -- Reverse the chapter list so that older items are listed first.

    chapters.Reverse()

end

function Login()

    -- We don't bother trying to log in by username/password if we've already got an access token.

    if(isempty(module.Data['access_token'])) then

        GetAccessToken(username, password)

        if(isempty(module.Data['access_token'])) then
            Fail(Error.LoginFailed)
        end
        
    end

end

function GetAuthorizationUrl()

    -- https://oauth.secure.pixiv.net/auth/token

    return 'https://oauth.secure.'..module.Domain..'/auth/token'

end

function GetApiUrl()

    -- https://app-api.pixiv.net

    return 'https://app-api.'..module.Domain

end

function AddAuthorizationHeader(http)

    RefreshAccessToken()

    -- Add the authorization header to the http object passed in, IF we have received an access token.

    if(not isempty(module.Data['access_token'])) then

        http.Headers.Add('Authorization', 'Bearer '..module.Data['access_token'])

    end

end

function PrepareHttpForAuthorization(http)

    -- Add all of the necessary common headers to the http object passed in to perform authorization.

    local clientId = 'KzEZED7aC0vird8jWyHM38mXjNTY'
    local clientSecret = 'W9JZoJe00qPvJsiyCGT3CCtC6ZUtdpKpzMbNlUGP'
    local loginSecret = '28c1fdd170a5204386cb1313c7077b34f83e4aaf4aa829ce78c231e05b0bae2c'

    local xClientTimeHeader = os.date("!%Y-%m-%dT%T+00:00")
    local xClientHashHeader = MD5(xClientTimeHeader..loginSecret):lower()

    http.Headers.Add('X-Client-Time', xClientTimeHeader)
    http.Headers.Add('X-Client-Hash', xClientHashHeader)

    http.PostData.Add('client_id', clientId)
    http.PostData.Add('client_secret', clientSecret)
    http.PostData.Add('get_secure_url', 1) 

end

function GetAccessToken(username, password)

    -- Get an access token by username and password.

    local http = Http.New()

    PrepareHttpForAuthorization(http)

    http.PostData.Add('grant_type', 'password')
    http.PostData.Add('username', username)
    http.PostData.Add('password', password)

    ReadAccessToken(Json.New(http.Post(GetAuthorizationUrl())))

end

function RefreshAccessToken()

    if(not isempty(module.Data['refresh_token']) and 
        not isempty(module.Data['expires_on']) 
        and os.time() >= tonumber(module.Data['expires_on'])) then

        -- Get an access token using the refresh token.

        local http = Http.New()

        PrepareHttpForAuthorization(http)

        http.PostData.Add('grant_type', 'refresh_token')
        http.PostData.Add('refresh_token', module.Data['refresh_token'])

        ReadAccessToken(Json.New(http.Post(GetAuthorizationUrl())))

        return not isempty(module.Data['refresh_token'])

    end

    -- Returning false indicates that we did not refresh the access token.

    return false

end

function ReadAccessToken(json)

    -- Read information about the access token from the JSON response we got from the API.

    module.Data['expires_on'] = (os.time() + tonumber(json.SelectValue('response.expires_in')))
    module.Data['access_token'] = json.SelectValue('response.access_token')
    module.Data['refresh_token'] = json.SelectValue('response.refresh_token')

end

function GetIllustrationJson(url)

    AddAuthorizationHeader(http)

    local id = StripParameters(url):regex('(\\d+)\\/*$', 1)
    local requestUrl = GetApiUrl()..'/v1/illust/detail?illust_id='..id

    return Json.New(http.Get(requestUrl))

end

function GetUserJson(url)

    AddAuthorizationHeader(http)

    local userId = StripParameters(url):regex('\\/users\\/(\\d+)', 1)
    local requestUrl = GetApiUrl()..'/v1/user/detail'

    requestUrl = SetParameter(requestUrl, 'user_id', userId)
    requestUrl = SetParameter(requestUrl, 'filter', 'for_ios')

    return Json.New(http.Get(requestUrl))

end

function GetIllustrationsJson(url, type, offset)

    AddAuthorizationHeader(http)

    local userId = StripParameters(url):regex('\\/users\\/(\\d+)', 1)
    local requestUrl = GetApiUrl()..'/v1/user/illusts'

    requestUrl = SetParameter(requestUrl, 'user_id', userId)
    requestUrl = SetParameter(requestUrl, 'type', type)
    requestUrl = SetParameter(requestUrl, 'offset', offset)
    requestUrl = SetParameter(requestUrl, 'filter', 'for_ios')

    return Json.New(http.Get(requestUrl))

end

function VerifyApiResponse(json)

    if(not isempty(json['error'])) then

        Log(json['error']['message'])

        Fail(Error.LoginRequired)

    end

end
