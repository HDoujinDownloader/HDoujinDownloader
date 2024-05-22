-- "Glossy Bright" is a common WordPress theme by Xhanch Studio.

function Register()

    module.Name = 'Glossy Bright'

    -- Thai translated content

    module = Module.New()
    
    module.Language = 'Thai'

    module.Domains.Add('niceoppai.net', 'Niceoppai')
    module.Domains.Add('www.niceoppai.net', 'Niceoppai')

    RegisterModule(module)

end

function GetInfo()

    -- Different sites may use different (translated) labels for each field, so checking the URL path is more reliable.

    info.Title = dom.SelectValue('//h1')
    info.Author = dom.SelectValues('//div[contains(@class, "det")]//a[contains(@href, "/author/")]')
    info.Artist = dom.SelectValues('//div[contains(@class, "det")]//a[contains(@href, "/artist/")]')
    info.Tags = dom.SelectValues('//div[contains(@class, "det")]//a[contains(@href, "/category/")]')

    -- Make sure we're on the first page of chapter pagination.

    info.Url = info.Url:before('/chapter-list/')

end

function GetChapters()

    -- The chapter list is paginated, with each page holding a maximum of 70 chapters.
    -- Pay attention to the pattern used for these kinds of loops to avoid potential cycles (encapsulate this behavior?).

    local lastPaginationUrl = ''
    local paginationUrls = List.New()

    repeat

        paginationUrls.Add(lastPaginationUrl)

        local chapterNodes = dom.SelectElements('//ul[contains(@class, "lst")]//a')

        -- Add all chapters on this page to the chapter list.

        for node in chapterNodes do

            local chapterTitle = node.SelectValue('b')
            local chapterUrl = node.SelectValue('@href')
    
            chapters.Add(chapterUrl, chapterTitle)
    
        end

        -- Get the URL of the next page.

        lastPaginationUrl = dom.SelectValue('//ul[contains(@class, "pgg")]/li/a[contains(text(), "Next")]/@href')

        if(not isempty(lastPaginationUrl)) then
            dom = dom.New(http.Get(lastPaginationUrl))
        end

    until(isempty(lastPaginationUrl) or paginationUrls.Contains(lastPaginationUrl) or chapters.Count() <= 0)

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@id, "image-container")]//img/@src'))

end
