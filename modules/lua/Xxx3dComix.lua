function Register()

    module.Name = 'XXX 3D Comix'
    module.Language = 'English'
    module.Adult = true

    module.Domains.Add('xxx3dcomix.com')

end

function GetInfo()

    info.Title = CleanTitle(dom.Title)
    info.Tags = dom.SelectValues('//ul[contains(@class,"tags")]//a')

    local pageCount = GetPageCount()

    if(pageCount > 0) then
        info.PageCount = pageCount
    else
        info.ChapterCount = GetTotalGalleryCount()
    end

end

function GetChapters()

    -- Don't use the "next" button, because it stops working at 10 pages in.

    for page in Paginator.New(http, dom, '//li[@class="cl active"]/following-sibling::li[1]') do

       chapters.AddRange(page.SelectElements('//li[@class="thumb"]/a'))

    end

    for chapter in chapters do

        chapter.Title = RegexReplace(chapter.Title, '^\\d+', ''):trim()

    end

    chapters.Reverse()

end

function GetPages()

    for page in Paginator.New(http, dom, '//a[contains(text(),"Next part")]/@href') do

        pages.AddRange(page.SelectValues('//figure/@data-href'))

    end

end

function CleanTitle(title)

    return RegexReplace(title, '(^Popular Hot free|, page \\d$| at XXX 3D Comix)', ''):trim()

end

function GetPageCount()

    pages = PageList.New()

    GetPages()

    return pages.Count()

end

function GetCurrentGalleryCount()

    return dom.SelectValues('//ul[contains(@class,"am-paid")]/li').Count()

end

function GetTotalGalleryCount()

    local galleriesPerPage = 100
    local lastPaginationUrl = dom.SelectValue('//li[@class="cl "][last()]/a/@href')

    if(isempty(lastPaginationUrl)) then
        return GetCurrentGalleryCount()
    end
    
    dom = dom.New(http.Get(lastPaginationUrl))

    local totalPaginationPages = tonumber(lastPaginationUrl:regex('\\d+$'))

    return ((totalPaginationPages - 1) * galleriesPerPage) + GetCurrentGalleryCount()

end
