function Register()

    module.Name = 'Seri Manga'
    module.Language = 'Turkish'

    module.Domains.Add('serimanga.com', 'Seri Manga')

end

local function CleanTitle(title)

    return tostring(title)
        :beforelast(' Manga Oku - Seri Manga')

end

function GetInfo()

    info.Title = dom.SelectValue('//div[contains(@class, "name")]')
    info.AlternativeTitle = dom.SelectValue('//div[contains(@class, "sub-text")]'):split(',')
    info.Summary = dom.SelectValues('//h3[contains(text(), "KONUSU")]/following-sibling::p'):join()
    info.Type = dom.SelectValue('//span[contains(text(), "Nedir")]/following-sibling::text()')
    info.DateReleased = dom.SelectValue('//span[contains(text(), "Yayınlanma Yılı")]/following-sibling::text()')
    info.Status = dom.SelectValue('//span[contains(text(), "Yayınlanması")]/following-sibling::div')
    info.Tags = dom.SelectValues('//span[contains(text(), "Kategori")]/following-sibling::div/a')
    info.ChapterCount = dom.SelectValue('//li[contains(@class, "spl-list-item")]/a/span')

    -- Make sure we're on the first page of chapter pagination.

    info.Url = RegexReplace(info.Url, '\\?page=\\d+$', '?page=1')

    -- If we have a reader URL, we need to get the title differently.

    if(isempty(info.Title)) then
        info.Title = CleanTitle(dom.Title)
    end

end

function GetChapters()

    -- Chapters are paginated into groups of 20 chapters.

    local lastPaginationUrl = ''
    local paginationUrls = List.New()

    repeat

        paginationUrls.Add(lastPaginationUrl)

        -- Add all chapters on the current page.

        for chapterNode in dom.SelectElements('//li[contains(@class, "spl-list-item")]/a') do

            local number = chapterNode.SelectValue('span')
            local title = chapterNode.SelectValue('span[2]')
            local url = chapterNode.SelectValue('@href')

            if(not isempty(title)) then
                title = number..' - '..title
            else
                title = number
            end

            chapters.Add(url, title)

        end

        -- Get the URL of the next page.

        lastPaginationUrl = dom.SelectValue('//a[@rel="next"]/@href')

        if(not isempty(lastPaginationUrl)) then
            dom = dom.New(http.Get(lastPaginationUrl))
        end

    until(isempty(lastPaginationUrl) or paginationUrls.Contains(lastPaginationUrl) or chapters.Count() <= 0)

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//img[contains(@class, "chapter-pages")]/@src'))
    pages.AddRange(dom.SelectValues('//img[contains(@class, "chapter-pages")]/@data-src'))

end
