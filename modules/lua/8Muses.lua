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

    -- 8muses.com pagination appends "/1"
    -- 8muses.io pagination appends "/page=1"

    return RegexReplace(tostring(url), '\\/(?:\\?page=)?\\d+([#?].+?)?$', ''):trim('/') .. '/'

end

local function SetPaginationIndex(url, index)

    if(module.Domain == '8muses.io') then
        url = CleanPaginationUrl(url) .. '?page=' .. index
    else
        url = CleanPaginationUrl(url) .. index
    end

    return url

end

local function GetAllAlbums(url)

    local albumList = ChapterList.New()
    local paginationCount = 1

    local url = CleanPaginationUrl(url)
    local dom = Dom.New(http.Get(url))
    local rootUrl = GetRoot(url)

    -- When paginating, some albums can show up twice (i.e. at the end of a page and the beginning of the next one).
    -- Keep track of what albums we've seen to avoid adding the same one more than once.

    local albumUrlDict = Dict.New()

    repeat

        local albumNodes = dom.SelectElements('//a[contains(@class,"c-tile") and .//span[contains(@class,"title-text")]]')

        if(albumNodes.Count() <= 0) then
            break
        end

        for i = 0, albumNodes.Count() - 1 do

            local albumNode = albumNodes[i]
            local albumUrl = GetRooted(albumNode.SelectValues('./@href'), rootUrl)
            local albumTitle = albumNode.SelectValue('.//span[contains(@class,"title-text")]')

            if(not albumUrlDict.ContainsKey(albumUrl)) then
                albumList.Add(albumUrl, albumTitle)
            end

            albumUrlDict[albumUrl] = albumUrl

        end

        paginationCount = paginationCount + 1

        if(paginationCount < MaxPagination) then
            dom = Dom.New(http.Get(SetPaginationIndex(url, paginationCount)))
        end

    until(paginationCount >=  MaxPagination)

    -- Album order is inconsistent, some albums listing older content before newer content.
    -- However, the trend seems to be listing older content first.

    return albumList
    
end

local function GetAllPages(url, albumPath)

    local dom = Dom.New(http.Get(url))

    local pageList = PageList.New()
    local pageUrls = dom.SelectValues('//a[contains(@class,"c-tile") and not(.//span[contains(@class,"title-text")])]//img/@data-src')

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
    
    -- Download images from nested albums recursively.

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

    -- Recursively add images from each nested album.

    for album in GetAllAlbums(url) do
        GetAllPagesRecursively(album.Url, albumPath .. '\\' .. album.Title, recursionDepth + 1)
    end

end

function GetInfo()

    info.Title = CleanTitle(dom.SelectValue('(//div[contains(@class,"top-menu-breadcrumb")]//li)[last()]'))

end

function GetChapters()

    -- If this directory has any images, we won't return any chapters.
    -- This is so we can still get the images in the current directory (the remaining albums can be downloaded recursively).

    if(GetAllPages(url).Count() > 0) then
        return
    end

    -- Note that albums are listed newest to oldest.

    for album in GetAllAlbums(url) do
        chapters.Add(album)
    end

end

function GetPages()

    local downloadAlbumsRecursively = toboolean(module.Settings['Download albums recursively'])

    if(downloadAlbumsRecursively) then

        GetAllPagesRecursively(url)

    else

        -- Simply download all images for the current album.

        for page in GetAllPages(url) do
            pages.Add(page)
        end

    end

end
