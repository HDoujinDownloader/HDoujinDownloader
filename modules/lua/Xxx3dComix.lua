function Register()

    module.Name = 'XXX 3D Comix'
    module.Language = 'English'
    module.Adult = true

    module.Domains.Add('3dcomixsex.com', '3D Comix Sex')
    module.Domains.Add('porncomix.pro', 'Porn Comix')
    module.Domains.Add('xxx3dcomix.com')

end

function GetInfo()

    info.Title = CleanTitle(dom.Title)
    info.Tags = dom.SelectValues('//*[contains(@class,"player-tags") or contains(@class,"gallery-tags")]//a')

    local pageCount = GetPageCount()

    if(pageCount > 0) then
        info.PageCount = pageCount
    else
        info.ChapterCount = GetTotalGalleryCount()
    end

end

function GetChapters()

    -- Don't use the "next" button, because it stops working at 10 pages in.

    local urlList = List.New()
    local titleList = List.New()

    for page in Paginator.New(http, dom, '//*[contains(@class,"pagination")]//li[contains(@class,"active")]/following-sibling::li[1]') do

        urlList.AddRange(page.SelectValues('//*[@itemprop="associatedMedia"]/a/@href'))
        titleList.AddRange(page.SelectValues('//*[@itemprop="associatedMedia"]//*[@itemprop="description"]'))

    end

    for i = 0, urlList.Count() - 1 do
        chapters.Add(urlList[i], titleList[i])
    end

    chapters.Reverse()

end

function GetPages()

    -- On 3dcomixsex.com we get can get the image URLs directly from the "sources" array.

    local sourcesArray = tostring(dom):regex('var\\s*sources\\s*=\\s*(\\[.+?\\])', 1)

    if(isempty(sourcesArray)) then

        for page in Paginator.New(http, dom, '//a[contains(text(),"Next part")]/@href') do

            pages.AddRange(page.SelectValues('//figure/@data-href'))
    
        end

    else

        pages.AddRange(Json.New(sourcesArray))

    end

end

function CleanTitle(title)

    return RegexReplace(title, '(^\\s*(?:Popular Hot free)|(?:, page \\d|at XXX 3D Comix|at 3d Comix Sex|3D Galleries and XXX 3D Comics)\\s*$)', '')
        :trim()

end

function GetPageCount()

    pages = PageList.New()

    GetPages()

    return pages.Count()

end

function GetCurrentGalleryCount()

    return dom.SelectValues('//div[contains(@class,"thumb-img-wrapper") or contains(@class,"item_wrapper")]').Count()

end

function GetTotalGalleryCount()

    local galleriesPerPage = GetCurrentGalleryCount()
    local lastPaginationUrl = dom.SelectValue('//*[contains(@class,"pagination")]//li[last()]/a/@href')

    if(isempty(lastPaginationUrl)) then
        return galleriesPerPage
    end
    
    dom = dom.New(http.Get(lastPaginationUrl))

    local totalPaginationPages = tonumber(lastPaginationUrl:regex('\\d+$'))

    return ((totalPaginationPages - 1) * galleriesPerPage) + GetCurrentGalleryCount()

end
