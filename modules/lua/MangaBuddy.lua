-- Sites using this module might have "Powered by MadTheme" in the lower right corner.
-- mangaxyz.com uses the same theme, so this module might be a duplicate.

require "MangaXyz"

local BaseGetPages = GetPages

function Register()

    module.Name = 'MangaBuddy'
    module.Language = 'en'

    module.Domains.Add('mangabuddy.com', 'MangaBuddy')
    module.Domains.Add('toonily.me', 'Toonily')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.AlternativeTitle = dom.SelectValue('//h2')
    info.Author = dom.SelectValues('//strong[contains(.,"Authors")]/following-sibling::a')
    info.Status = dom.SelectValues('//strong[contains(.,"Status")]/following-sibling::a')
    info.Tags = dom.SelectValues('//strong[contains(.,"Genres")]/following-sibling::a')
    info.Summary = dom.SelectValue('//p[contains(@class,"content")]')

end

function GetChapters()

    for chapterNode in dom.SelectElements('//ul[@id="chapter-list"]//a') do

        local chapterUrl = chapterNode.SelectValue('@href')
        local chapterTitle = chapterNode.SelectValue('.//*[contains(@class,"chapter-title")]')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    local chapImagesScript = dom.SelectValue('//script[contains(.,"chapImages")]')

    if(isempty(chapImagesScript)) then
        pages.AddRange(dom.SelectValues('//div[@id="chapter-images"]//img/@data-src'))
    else
        BaseGetPages()
    end

end
