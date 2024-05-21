function Register()

    module.Name = 'MangaJar'
    module.Language = 'English'

    module.Domains.Add('mangajar.com', 'MangaJar')

end

local function GetApiResponse(requestUri)

    local csrfToken = dom.SelectValue('//meta[@name="csrf-token"]/@content')

    http.Headers['Accept'] = '*/*'
    http.Headers['X-Requested-With'] = 'XMLHttpRequest'
    http.Headers['X-CSRF-TOKEN'] = csrfToken

    return http.Get(requestUri)

end

function GetInfo()

    info.Title = dom.SelectValue('//span[contains(@class, "post-name")]')
    info.Type = dom.SelectValue('//h1/text()')
    info.AlternativeTitle = dom.SelectValue('//span[contains(@class, "post-name-jp")]'):after('/')
    info.Status = dom.SelectValue('//b[contains(text(), "Status")]//following-sibling::text()')
    info.Tags = dom.SelectValues('//span[contains(b/text(), "Genre")]//following-sibling::span//a')
    info.DateReleased = dom.SelectValue('//span[contains(b/text(), "Year")]//following-sibling::span//a')
    info.Summary = dom.SelectValue('//div[contains(@class, "manga-description")]')
    info.ChapterCount = dom.SelectValue('//b[contains(text(), "Chapters")]//following-sibling::text()')

    if(isempty(info.Title)) then
        info.Title = dom.SelectValue('//h1')
    end

end

function GetChapters()

    doc = http.Get(url)

    local slug = doc:regex("let\\s*manga\\s*=\\s*'([^']+)'", 1)
    local apiUrl = '/manga/'..slug..'/chaptersList'

    dom = Dom.New(GetApiResponse(apiUrl))

    chapters.AddRange(dom.SelectElements('//a[span]'))

    chapters.Reverse()

end

function GetPages()
   
    for imageNode in dom.SelectElements('//div[contains(@class, "chapter-container")]//img') do

        -- Sometimes the first image will only have the image in the "src" attribute while the rest use "data-src".

        local pageUrl = imageNode.SelectValue('@data-src')

        if(isempty(pageUrl)) then
            pageUrl = imageNode.SelectValue('@src')
        end

        pages.Add(pageUrl)

    end

end
