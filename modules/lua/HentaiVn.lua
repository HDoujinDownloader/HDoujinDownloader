function Register()

    module.Name = 'HentaiVN'
    module.Language = 'Vietnamese'
    module.Adult = true

    module.Domains.Add('hentaivn.moe')
    module.Domains.Add('hentaivn.net')
    module.Domains.Add('hentaivn.tv')

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

    pages.AddRange(dom.SelectValues('//div[@id="image" or @id="content_chap"]/img/@src'))

end

function CleanTitle(title)

    return RegexReplace(tostring(title), '(?:^Đọc Online:|Full$)', '')
        :trim()

end
