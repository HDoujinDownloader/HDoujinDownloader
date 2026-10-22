local MaxPagination = 25
local MaxRecursion = 5

function Register()
    module.Name = '8muses'
    module.Language = 'en'
    module.Adult = true
    module.Domains.Add('8muses.com')
    module.Domains.Add('8muses.io')
    module.Domains.Add('comics.8muses.com')
    module.Settings.AddCheck('Download albums recursively', false)
end

local function CleanTitle(title)
    return tostring(title):before('|')
end

local function CleanPaginationUrl(url)
    return RegexReplace(tostring(url), '\\/(?:\\?page=)?\\d+([#?].+?)?$', ''):trim('/') .. '/'
end

local function SetPaginationIndex(url, index)
    return CleanPaginationUrl(url) .. '?page=' .. index
end

local function GetAllAlbums(url)
    local albumList = ChapterList.New()
    local paginationCount = 1
    local cleanUrl = CleanPaginationUrl(url)
    local dom = Dom.New(http.Get(cleanUrl))
    local rootUrl = GetRoot(cleanUrl)
    local albumUrlDict = Dict.New()

    repeat
        local albumNodes = dom.SelectElements('//a[contains(@class,"c-tile") and .//span[contains(@class,"title-text")]]')
        
        if(albumNodes.Count() <= 0) then
            break
        end

        for i = 0, albumNodes.Count() - 1 do
            local albumNode = albumNodes[i]
            local href = albumNode.SelectValue('./@href')
            local albumUrl = href:match('^http') and href or (rootUrl .. href:gsub('^%/', ''))
            local albumTitle = albumNode.SelectValue('.//span[contains(@class,"title-text")]')

            if(not albumUrlDict.ContainsKey(albumUrl)) then
                albumList.Add(albumUrl, albumTitle)
            end

            albumUrlDict[albumUrl] = albumUrl
        end

        paginationCount = paginationCount + 1

        if(paginationCount < MaxPagination) then
            dom = Dom.New(http.Get(SetPaginationIndex(cleanUrl, paginationCount)))
        end
    until(paginationCount >=  MaxPagination)

    return albumList
end

local function GetAllPages(url, albumPath)
    local dom = Dom.New(http.Get(url))
    local pageList = PageList.New()
    
    -- Target @src due to site updates removing @data-src
    local pageUrls = dom.SelectValues('//a[contains(@class,"c-tile") and not(.//span[contains(@class,"title-text")])]//img/@src')
    
    -- Fallback in case legacy pages still use @data-src
    if(pageUrls.Count() == 0) then
        pageUrls = dom.SelectValues('//a[contains(@class,"c-tile") and not(.//span[contains(@class,"title-text")])]//img/@data-src')
    end

    for pageUrl in pageUrls do
        pageUrl = pageUrl:replace('/th/', '/fl/')
        pageUrl = pageUrl:replace('/th_', '/full_')
        local page = PageInfo.New(pageUrl)

        if(not isempty(albumPath)) then
            page.DirectoryPath = albumPath
        end

        pageList.Add(page)
    end

    return pageList
end

local function GetAllPagesRecursively(url, albumPath, recursionDepth)
    if(isempty(recursionDepth)) then
        recursionDepth = 0
    end

    if(isempty(albumPath)) then
        albumPath = ''
    end

    if(recursionDepth >= MaxRecursion) then
        return
    end

    for page in GetAllPages(url, albumPath) do
        pages.Add(page)
    end

    for album in GetAllAlbums(url) do
        GetAllPagesRecursively(album.Url, albumPath .. '\\' .. album.Title, recursionDepth + 1)
    end
end

function GetInfo()
    info.Title = CleanTitle(dom.SelectValue('(//div[contains(@class,"top-menu-breadcrumb")]//li)[last()]'))
end

function GetChapters()
    local pageCheck = GetAllPages(url)
    if(pageCheck.Count() > 0) then
        return
    end

    for album in GetAllAlbums(url) do
        chapters.Add(album)
    end
end

function GetPages()
    local downloadAlbumsRecursively = toboolean(module.Settings['Download albums recursively'])

    if(downloadAlbumsRecursively) then
        GetAllPagesRecursively(url)
    else
        for page in GetAllPages(url) do
            pages.Add(page)
        end
    end
end
