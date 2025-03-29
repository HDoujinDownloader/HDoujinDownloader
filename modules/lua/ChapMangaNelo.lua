require "Manganelo"

local baseGetInfo = GetInfo

local function getImageUrlsFromNextJs()

    local nextJsData = dom.SelectValue('//script[contains(text(),"pagesV2")]')
    local imagesArray = nextJsData:regex('pagesV2.+?(\\[.+?\\])', 1)

    return imagesArray:regexmany('\\\\?"([^\\\\"]+)\\\\?"', 1)

end

function Register()

    module.Name = "ChapMangaNelo"
    module.Language = "English"

    module.Domains.Add("chapmanganelo.org")

end

function GetInfo()

    baseGetInfo()

    info.Author = dom.SelectValues('//td[contains(text(),"Author")]//following-sibling::td//a')
    info.Status = dom.SelectValue('//td[contains(text(),"Status")]//following-sibling::td')
    info.Tags = dom.SelectValues('//td[contains(text(),"Genres")]//following-sibling::td//a')
    info.Summary = dom.SelectValue('//p[contains(text(),"Description:")]//following-sibling::div/div[contains(@aria-label,"content")]')

end

function GetChapters()
    chapters.AddRange(dom.SelectElements('//section[contains(@id, "chapter-list")]//a'))
end

function GetPages()
    pages.AddRange(getImageUrlsFromNextJs())
end
