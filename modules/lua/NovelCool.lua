require "NineManga" -- Uses the same reader

local BaseGetPages = GetPages

function Register()

    module.Name = 'Novel Cool'
    module.Language = 'en'

    module.Domains.Add('novelcool.com')
    module.Domains.Add('www.novelcool.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Author = dom.SelectValue('//div[contains(@class,"bookinfo-author")]')
    info.Summary = dom.SelectValue('//div[contains(@class,"bk-summary-txt")]')
    info.Status = dom.SelectValue('//div[contains(@class,"bk-going")]')
    info.Tags = dom.SelectValues('//div[contains(@class,"bk-cate-item")]//a/span')

end

function GetPages()

    -- The referer must be blank, or we get an invalid response.

    http.Referer = ''

    BaseGetPages()

end

function GetChapters()

    for chapterNode in dom.SelectElements('//div[contains(@class,"chp-item")]') do

        local chapterUrl = chapterNode.SelectValue('.//@href')
        local chapterTitle = chapterNode.SelectValue('.//span[contains(@class,"chapter-item-headtitle")]')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end
