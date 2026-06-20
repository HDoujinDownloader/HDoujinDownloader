function Register()

    module.Name = 'KunManga'
    module.Language = 'English'

    module.Domains.Add('kunmanga.co.uk', 'KunManga UK')
    module.Domains.Add('www.kunmanga.co.uk', 'KunManga UK')

    RegisterModule(module)

end

local function GetSlug()

    return url:regex('/manga/([^/?#]+)', 1)

end

function GetInfo()

    info.Title = dom.SelectValue('//div[contains(@class,"post-title")]//h1')

    if(isempty(info.Title)) then
        info.Title = dom.SelectValue('//h1')
    end

    info.AlternativeTitle = dom.SelectValue('//div[contains(h5/text(), "Alternative")]/following-sibling::div')
    info.Author = dom.SelectValues('//div[contains(h5/text(), "Author")]/following-sibling::div//a')
    info.Artist = dom.SelectValues('//div[contains(h5/text(), "Artist")]/following-sibling::div//a')
    info.Tags = dom.SelectValues('//div[contains(@class, "genres-content")]//a')
    info.Type = dom.SelectValue('//div[contains(h5/text(), "Type")]/following-sibling::div')
    info.DateReleased = dom.SelectValue('//div[contains(h5/text(), "Release")]/following-sibling::div')
    info.Status = dom.SelectValue('//div[contains(h5/text(), "Status")]/following-sibling::div')
    info.Summary = dom.SelectValues('//div[contains(@class, "description-summary")]//p'):join('\n\n')

    if(isempty(info.Summary)) then
        info.Summary = dom.SelectValue('//div[contains(@class, "description-summary")]')
    end

    info.Title = tostring(info.Title):trim()

end

function GetChapters()

    local host = GetHost(url)
    local slug = GetSlug()
    local currentPage = 1
    local lastPage = 1

    repeat

        local endpoint = 'https://' .. host .. '/api/comics/' .. slug .. '/chapters?page=' .. currentPage .. '&per_page=100&order=asc'
        local json = Json.New(http.Get(endpoint))

        local lastPageValue = json.SelectValue('data.last_page')

        if(isnumber(lastPageValue)) then
            lastPage = tonumber(lastPageValue)
        end

        for chapterNode in json.SelectTokens('data.chapters[*]') do

            local chapterSlug = chapterNode.SelectValue('chapter_slug')
            local chapterTitle = chapterNode.SelectValue('chapter_name')

            if(not isempty(chapterSlug)) then

                local chapterUrl = 'https://' .. host .. '/manga/' .. slug .. '/' .. chapterSlug

                chapters.Add(chapterUrl, chapterTitle)

            end

        end

        currentPage = currentPage + 1

    until currentPage > lastPage

end

function GetPages()

    local loginRequired = dom.SelectElements('//div[contains(@class,"reading-content")]//div[contains(@class,"login-required")]').Count() > 0

    if(loginRequired) then
        Fail(Error.LoginRequired)
    end

    pages.Referer = 'https://' .. GetHost(url) .. '/'

    pages.AddRange(dom.SelectValues('//div[contains(@class, "reading-content")]//img[contains(@class, "wp-manga-chapter-img")]/@src'))

    if(isempty(pages)) then
        pages.AddRange(dom.SelectValues('//div[contains(@class, "reading-content")]//img[contains(@class, "wp-manga-chapter-img")]/@data-src'))
    end

    for page in pages do
        if(not isempty(page.Url)) then
            page.Url = page.Url:replace('&#039;', '\'')
        end
    end

end
