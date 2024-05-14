function Register()

    module.Name = 'Reaper Scans'
    module.Language = 'English'
    module.Adult = false

    module.Domains.Add('reaperscans.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Summary = dom.SelectValue('//h1[contains(text(),"Summary")]/following-sibling::p')
    info.AlternativeTitle = dom.SelectValue('//div[h5[contains(text(),"Alternative")]]/following-sibling::div')
    info.Author = dom.SelectValues('//div[contains(@class,"author-content")]/a')
    info.Artist = dom.SelectValues('//div[contains(@class,"artist-content")]/a')
    info.Tags = dom.SelectValues('//div[contains(@class,"genres-content")]/a')
    info.Type = dom.SelectValue('//div[h5[contains(text(),"Type")]]/following-sibling::div')
    info.DateReleased = dom.SelectValue('//div[h5[contains(text(),"Release")]]/following-sibling::div/a')
    info.Status = dom.SelectValue('//dt[contains(text(),"Source Status")]/following-sibling::dd')

    local chapterCount = dom.SelectValue('//span[text()="of"]/following-sibling::span')

    if(not isempty(chapterCount)) then
        info.ChapterCount = chapterCount
    end

end

function GetChapters()

    local maxPageIndex = dom.SelectElements('//span[contains(@*,"paginator-page")]').Count()

    if(maxPageIndex <= 0) then
        maxPageIndex = 1
    end

    for currentPageIndex = 1, maxPageIndex do

        http.Referer = url

        url = SetParameter(url, 'page', currentPageIndex)
        dom = Dom.New(http.Get(url))

        local chapterNodes = dom.SelectElements('(//ul[@role="list"])[1]//a[contains(@href,"/chapters/")]')

        for i = 0, chapterNodes.Count() - 1 do

            local chapterNode = chapterNodes[i]
            local chapter = ChapterInfo.New()

            chapter.Url = chapterNode.SelectValue('./@href')
            chapter.Title = chapterNode.SelectValue('.//p')
            
            chapters.Add(chapter)

        end

        sleep(300)

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//main//img[contains(@src,"media.reaperscans.com") or contains(@class,"max-w-full mx-auto display-block")]/@src'))

end
