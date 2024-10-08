function Register()

    module.Name = 'HentaiVN'
    module.Language = 'Vietnamese'
    module.Adult = true

    module.Domains.Add('ayamehentai.cc')
    module.Domains.Add('hentaiayame.net')
    module.Domains.Add('hentaivn.la')
    module.Domains.Add('hentaivn.moe')
    module.Domains.Add('hentaivn.net')
    module.Domains.Add('hentaivn.tv')

    module.Settings.AddChoice('Image server', 'Auto', { 'Auto', 'Server 1', 'Server 2' })

end

local function CleanTitle(title)

    return RegexReplace(tostring(title), '(?:^Đọc Online:|Full$)', '')
        :trim()

end

local function GetPageCount()

    pages = PageList.New()

    GetPages()

    return pages.Count()

end

function GetInfo()

    info.Title = dom.SelectValue('//h1[@itemprop="name"]')
    info.Tags = dom.SelectValues('//span[contains(text(),"Thể Loại")]/following-sibling::span')
    info.Translator = dom.SelectValues('//span[contains(text(),"Nhóm dịch")]/following-sibling::span/a')
    info.Author = dom.SelectValues('//span[contains(text(),"Tác giả")]/following-sibling::span/a')
    info.Status = dom.SelectValues('//span[contains(text(),"Tình Trạng")]/following-sibling::span[1]/a')
    info.Summary = dom.SelectValue('//p[contains(.,"Nội dung")]/following-sibling::p')
    
    -- Get title from the reader.

    if(isempty(info.Title)) then
        info.Title = CleanTitle(dom.Title)
    end

    -- Set the page count right away if pages are available, because otherwise GetChapters will succeed.

    local pageCount = GetPageCount()

    if(pageCount > 0) then
        info.PageCount = pageCount
    end

end

function GetChapters()

    local chaptersXPath = '//table[contains(@class,"listing")]//a'

    chapters.AddRange(dom.SelectElements(chaptersXPath))

    if(isempty(chapters)) then

        -- We need to make another request to get the chapters list, because they're not embedded directly on the page anymore.

        local chapterId = url:regex('\\/(\\d+)-', 1)
        local chapterSlug = url:regex('doc-truyen-([^.]+?)\\.html', 1)
        local endpoint = '/list-showchapter.php?idchapshow=' .. chapterId .. '&idlinkanime=' .. chapterSlug

        http.Headers['accept'] = '*/*'

        dom = Dom.New(http.Get(endpoint))

        chapters.AddRange(dom.SelectElements(chaptersXPath))

    end

    chapters.Reverse()

end

function GetPages()

    local imageServer = module.Settings['Image server']

    if(imageServer == 'Server 1' or imageServer == 'Auto') then

        -- "Server 1" is the default, so we'll just get the images directly from the page.

        -- Read the "data-src" attribute first, because the "src" attribute is just a loading spinner.
        -- The latter is kept just in case there are chapters that haven't been updated to use the new attribute.

        pages.AddRange(dom.SelectValues('//div[@id="image" or @id="content_chap"]/img/@data-src'))

        if(isempty(pages)) then
            pages.AddRange(dom.SelectValues('//div[@id="image" or @id="content_chap"]/img/@src'))
        end

    else

        -- We need to request the images from Server 2.

        local chapterId = url:regex('\\/(?:\\d+)-(\\d+)', 1)
        local endpoint = '/ajax_load_server.php'

        http.Headers['accept'] = '*/*'
        http.Headers['origin'] = 'https://' .. module.Domain
        http.Headers['x-requested-with'] = 'XMLHttpRequest'

        http.PostData['server_id'] = chapterId
        http.PostData['server_type'] = '2'

        dom = Dom.New(http.Post(endpoint))

        pages.AddRange(dom.SelectValues('//img/@src'))        

    end

    pages.Referer = url

end
