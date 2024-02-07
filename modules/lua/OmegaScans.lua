function Register()

    module.Name = 'Omega Scans'
    module.Language = 'English'
    module.Adult = true

    module.Domains.Add('omegascans.org')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Summary = dom.SelectValue('//h5[contains(text(),"Description")]//following-sibling::div/p')
    info.AlternativeTitle = dom.SelectValue('//h1//following-sibling::p')
    info.DateReleased = dom.SelectValue('//p[contains(text(),"Release year")]/strong')
    info.Author = dom.SelectValue('//p[contains(text(),"Author: ")]/strong')
    info.Artist = dom.SelectValue('//p[contains(text(),"Author: ")]/strong')
    info.Scanlator = module.Name
    info.Publisher = dom.SelectValue('//p[contains(text(),"This is a series produced by")]/strong')

    local checkEndStatus = dom.SelectValue(
        '//div[@id="radix-:R4hmmmeja:-content-1"]/ul//a[starts-with(@href, "/series/")][1]//li//span[contains(@class, "line-clamp-1" ) and contains(text(),"END") or contains(text(),"end")]')

    if (not isempty(checkEndStatus)) then
        info.Status = 'Completed'
    end

end

function GetChapters()

    for chapterNode in dom.SelectElements('//div[contains(@role,"tabpanel")]//a[contains(@href,"/series/")]') do
        
        local isPremiumChapter = chapterNode.SelectElements('.//span/*[name()="svg"]').Count() > 0

        if(not isPremiumChapter) then

            local chapterUrl = chapterNode.SelectValue('@href')
            local chapterTitle = chapterNode.SelectValue('.//li//span[contains(@class, "line-clamp-1")]')
            
            chapters.Add(chapterUrl, chapterTitle)

        end

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//img[contains(@data-src, "/uploads/series/")]/@data-src|//img[contains(@src, "/uploads/series/")]/@src'))

end
