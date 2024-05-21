local MaxPagination = 25
local MaxRecursion = 5

function Register()

    module.Name = "Eka's Portal"
    module.Type = 'artist cg'

    module.Domains.Add('aryion.com')

    module.Settings.AddCheck('Download folders recursively', true)
    module.Settings.AddCheck('Create subfolders', true)

end

local function SetPaginationIndex(url, index)

    url = SetParameter(url, 'p', index)

    return url

end

local function GetAllFolders(url)

    local folderList = ChapterList.New()

    -- Get the pagination index we will start paginating from.

    local currentPaginationIndex = GetParameter(url, 'p')

    if(isempty(currentPaginationIndex)) then
        currentPaginationIndex = 1
    end

    local paginationIndex = tonumber(currentPaginationIndex)

    repeat

        local folderNodes = dom.SelectElements('//li[contains(@class,"gallery-item") and .//span[contains(@class,"type-Folder") or contains(@class,"type-Comics")]]')

        if(folderNodes.Count() <= 0) then
            break
        end

        for i = 0, folderNodes.Count() - 1 do

            local folderNode = folderNodes[i]
            local folderUrl = folderNode.SelectValues('.//@href')
            local folderTitle = folderNode.SelectValue('.//p[contains(@class,"item-title")]')

            folderList.Add(folderUrl, folderTitle)

        end

        paginationIndex = paginationIndex + 1

        if(paginationIndex < MaxPagination) then
            dom = Dom.New(http.Get(SetPaginationIndex(url, paginationIndex)))
        end
    
    until(paginationIndex >= MaxPagination)

    -- While it's not always the case, assume folders are listed in reverse chronological order.

    folderList.Reverse()

    return folderList
    
end

local function GetAllPages(url, folderPath)

    local createSubfolders = toboolean(module.Settings['Create subfolders'])

    local dom = Dom.New(http.Get(url))
    local pageList = PageList.New()
    local pageUrls = dom.SelectValues('//li[contains(@class,"gallery-item") and not(.//span[contains(@class,"type-Folder") or contains(@class,"type-Comics")])]//@href')

    for pageUrl in pageUrls do

        local page = PageInfo.New(pageUrl)

        if(createSubfolders and not isempty(folderPath)) then
            page.DirectoryPath = folderPath
        end

        pageList.Add(page)

    end

    -- Pages are listed in reverse chronological order.

    pageList.Reverse()

    return pageList

end

local function GetAllPagesRecursively(url, folderPath, recursionDepth)
    
    -- Download images from nested folders recursively.

    if(isempty(recursionDepth)) then
        recursionDepth = 0
    end

    if(isempty(folderPath)) then
        folderPath = ''
    end

    if(recursionDepth >= MaxRecursion) then
        return
    end

    for page in GetAllPages(url, folderPath) do
        pages.Add(page)
    end

    -- Recursively add images from each nested folder.

    for folder in GetAllFolders(url) do
        GetAllPagesRecursively(folder.Url, folderPath .. '\\' .. folder.Title, recursionDepth + 1)
    end

end

local function GetWorkMetadata(dom, page)

    -- Get the filename and direct download URL.

    local variablesScript = dom.SelectValue('//script[contains(text(),"itemTitle")]')

    local filename = variablesScript:regex('itemTitle\\s*=\\s*"([^"]+)', 1)
    local downloadUrl = dom.SelectValue('//div[contains(@class,"func-box")]//a[contains(text(),"Download")]/@href')
    local baseUrl = dom.SelectValue('//base/@href')
    local mimeType = dom.SelectValue('//b[contains(text(),"MIME Type")]/following-sibling::text()'):after(':'):trim()

    page.Referer = page.Url

    if(mimeType == 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') then

        -- We have a word document.

        downloadUrl = dom.SelectValue('//iframe/@src')

        page.FileExtensionHint = '.docx'

    elseif(mimeType == 'video/mp4') then

        -- We have a video.

        downloadUrl = dom.SelectValue('//video//@src')

        page.FileExtensionHint = '.mp4'

    elseif(mimeType == 'application/x-shockwave-flash') then

        -- We have an Adobe Flash file.

        downloadUrl = dom.SelectValue('//script[contains(text(),"embedSWF")]'):regex('embedSWF\\("([^"]+)', 1)

        page.FileExtensionHint = '.swf'

    else

        -- We have a basic image (probably).

        -- For content that requires a login, we might get a 401 error when attempting to download it.
        -- I'm not totally sure why this is happening even when logged in, but we can just get the image URL instead.

        local unescapedImageUrl = variablesScript:regex('data_path":("[^"]+")', 1)

        if(not isempty(unescapedImageUrl)) then

            local imageUrl = tostring(Json.New(unescapedImageUrl))

            page.BackupUrls.Add(imageUrl)

        end

    end

    if(not isempty(filename)) then
        page.FilenameHint = filename
    end

    if(not isempty(downloadUrl)) then
        page.Url = GetRooted(downloadUrl, baseUrl)
    end

end

function GetInfo()

    info.Title = dom.SelectValue('//span[contains(@class,"g-box-title")]')
    info.Summary = dom.SelectValue('//div[contains(@class,"g-box-contents")]/p')
    info.Artist = dom.SelectValue('//div[contains(@id,"userpagetabs")]//a[contains(@href,"/user/")]')
    info.Tags = dom.SelectValues('//span[contains(@class,"taglist")]//a')

end

function GetChapters()

    -- If this directory has any images, we won't return any chapters (folders).
    -- This is so we can still get the images in the current directory (the remaining folders can be downloaded recursively).

    if(GetAllPages(url).Count() > 0) then
        return
    end

    for folder in GetAllFolders(url) do
        chapters.Add(folder)
    end

end

function GetPages()

    local downloadFoldersRecursively = toboolean(module.Settings['Download folders recursively'])
    
    if(downloadFoldersRecursively) then

        GetAllPagesRecursively(url)

    else

        -- Simply download all images for the current folder.

        for page in GetAllPages(url) do
            pages.Add(page)
        end

    end

    if(isempty(pages)) then
        
        -- The URL might be a single work.

        local pageInfo = PageInfo.New()

        GetWorkMetadata(dom, pageInfo)

        pages.Add(pageInfo)

    end

end

function BeforeDownloadPage()

    GetWorkMetadata(dom, page)

end

function Login()

    if(isempty(http.Cookies)) then

        http.Referer = 'https://'..module.Domain
        
        local loginEndpoint = 'https://' .. module.Domain .. '/forum/ucp.php?mode=login'
        local dom = Dom.New(http.Get(loginEndpoint))

        http.PostData.Add('username', username)
        http.PostData.Add('password', password)
        http.PostData.Add('autologin', 'on')
        http.PostData.Add('viewonline', 'on')
        http.PostData.Add('redirect', dom.SelectValue('//input[@name="redirect"]/@value'))
        http.PostData.Add('sid', dom.SelectValue('//input[@name="sid"]/@value'))
        http.PostData.Add('login', dom.SelectValue('//input[@name="login"]/@value'))

        local response = http.PostResponse(loginEndpoint)

        dom = Dom.New(response.Body)

        if(isempty(dom.SelectElements('//a[contains(@title,"Logout")]'))) then
            Fail(Error.LoginFailed)
        end

        global.SetCookies(response.Cookies)

    end

end
