local function isTagsPage()
    return isempty(dom.SelectElement('//h1[contains(@class,"entry-title")]'))
end

local function enqueueAllEntriesForTag()

    for entryUrl in dom.SelectValues('//a[contains(@class,"entry-title-link")]/@href') do

        Enqueue(entryUrl)

    end

    local nextUrl = dom.SelectValue('//li[contains(@class,"pagination-next")]/a/@href')

    if(not isempty(nextUrl)) then

        Enqueue(nextUrl)

    end

end

function Register()

    module.Name = 'MyReadingManga'
    module.Language = 'English'
    module.Adult = true

    module.Domains.Add('myreadingmanga.info', 'MyReadingManga')

end

function GetInfo()

    if(isTagsPage()) then

        enqueueAllEntriesForTag()

        info.Ignore = true

    else

        info.Title = dom.SelectValue('//h1')
        info.Tags = dom.SelectValues('//header//a[@rel="tag"]')
        info.Language = dom.SelectValue('//span[contains(text(),"Language:")]/a')
        info.Author = dom.SelectValue('//span[contains(text(),"Author:")]/a')
        info.Circle = dom.SelectValue('//span[contains(text(),"Circle:")]/a')
        info.Type = dom.SelectValue('//span[contains(text(),"Filed Under:")]/a')
        info.Status = dom.SelectValue('//span[contains(text(),"Status:")]/a')
        info.Summary = dom.SelectValues('//div[contains(@class,"entry-content")]/p'):join('\n')

        if(isempty(info.Artist)) then
            info.Artist = info.Title:regex('^\\[(.+?)\\]', 1)
        end

        if(isempty(info.Author)) then
            info.Author = info.Summary:regex('\\Author:\\s*(.+?)\n', 1)
        end

        if(isempty(info.Circle)) then
            info.Circle = info.Summary:regex('\\bCircle:\\s*(.+?)\n', 1)
        end

        -- Some entries have multiple chapters.
        -- e.g. https://myreadingmanga.info/nakagawa-riina-kabeana-money-hole-eng/

        local chapterNumber = dom.Title:regex('\\s-\\sPage\\s(\\d+)\\sof', 1)

        if(not isempty(chapterNumber)) then

            info.Title = info.Title..FormatString(' - Chapter {0}', chapterNumber)

        end

    end

end

function GetChapters()

    local titleTemplate = dom.SelectValue('//h1')
    local urlTemplate = Regex.Replace(StripParameters(url), '\\/\\d+\\/$', '')
    local chapterCount = dom.SelectElements('//div[contains(@class,"pagination")]/a[not(.//i)]').Count() + 1

    if(chapterCount > 1) then

        for i = 1, chapterCount do

            chapters.Add(urlTemplate..FormatString('/{0}/', i), titleTemplate..FormatString(' - Chapter {0}', i))

        end

    end

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"entry-content")]//img/@data-src'))

    if(isempty(pages)) then
        pages.AddRange(dom.SelectValues('//div[contains(@class,"entry-content")]//img/@data-lazy-src'))
    end

    if(isempty(pages)) then
        pages.AddRange(dom.SelectValues('//div[contains(@class,"entry-content")]//img/@src'))
    end

end
