function Register()

    module.Name = 'Luscious'
    module.Domains.Add('luscious.net')

end

function GetInfo()

    if(url:contains('/albums/')) then

        -- User added an album URL (note that doujins are also treated as albums).
        -- This is all this module supports for now, so you can disable it if you want to fall back to the more full-featured internal module.
        
        local id = GetAlbumIdFromUrl(url)
        local json = GetAlbumJson(id)

        info.Title = json.SelectValue('title')
        info.Language = json.SelectValue('language.title'):before('/')
        info.Tags = json.SelectValues('tags[*].text')
        info.Summary = json.SelectValue('description')
        info.PageCount = json.SelectValue('number_of_pictures')

    end

end

function GetPages()

    if(url:contains('/albums/')) then

        -- User added an album URL (note that doujins are also treated as albums).

        local id = GetAlbumIdFromUrl(url)
        local json = GetAlbumImagesJson(id, 1)

        -- We'll have the first pagination results, along with some extra information we can use to get the rest of the images.
        
        local totalPages = tonumber(json.SelectValue('info.total_pages'))

        for i = 2, totalPages + 1 do

            pages.AddRange(json.SelectValues('items[*].url_to_original'))

            if(i <= totalPages) then

                json = GetAlbumImagesJson(id, i)

            end

        end

    end

end

function Login()
    
    if(not http.Cookies.Contains('has_login_session')) then

        -- We don't appear to be logged in already, so make a login attempt.

        local domain = module.Domain

        http.Referer = 'https://members.'..domain..'/login/'
        
        local dom = Dom.New(http.Get('https://members.'..domain..'/login/'))
        
        http.PostData.Add('login', username)
        http.PostData.Add('password', password)
        http.PostData.Add('remember', 'on')
        http.PostData.Add('next', dom.SelectValue('//form[@id="site_login"]//input[@name="next"]/@value'))
        
        local response = http.PostResponse('https://members.'..domain..'/accounts/login/')

        if(not response.Cookies.Contains('has_login_session')) then
            Fail(Error.LoginFailed)
        end

        global.SetCookies(response.Cookies)

    end

end

function GetAlbumIdFromUrl(url)

    return url:regex('(\\d+)\\/*$', 1)

end

function GetApiBaseUrl()

    -- https://api.luscious.net/graphql/nobatch/

    return 'https://api.'..module.Domain..'/graphql/nobatch/'

end

function GetAlbumJson(id)

    local requestUri = GetApiBaseUrl()..'?operationName=AlbumGet&query= query AlbumGet($id: ID!) { album { get(id: $id) { ... on Album { ...AlbumStandard } ... on MutationError { errors { code message } } } } } fragment AlbumStandard on Album { id title description number_of_pictures is_manga url download_url cover { url } content { id title url } language { id title url } tags { category text url count } genres { id title slug url } audiences { id title url url } } &variables={"id":"'..id..'"}'

    return Json.New(http.Get(requestUri)).SelectToken('data.album.get')

end

function GetAlbumImagesJson(id, pageIndex)

    local requestUri = GetApiBaseUrl()..'?operationName=AlbumListOwnPictures&query= query AlbumListOwnPictures($input: PictureListInput!) { picture { list(input: $input) { info { ...FacetCollectionInfo } items { ...PictureStandardWithoutAlbum } } } } fragment FacetCollectionInfo on FacetCollectionInfo { page has_next_page total_items total_pages items_per_page } fragment PictureStandardWithoutAlbum on Picture { url_to_original } &variables={"input":{"filters":[{"name":"album_id","value":"'..id..'"}],"display":"position","page":'..pageIndex..'}}'

    return Json.New(http.Get(requestUri)).SelectToken('data.picture.list')

end
