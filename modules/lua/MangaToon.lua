function Register()

    module.Name = 'Manga Toon'
    module.Language = 'en'
    module.Adult = false

    module.Domains.Add('mangatoon.mobi')

end

function GetInfo()

    info.Title = dom.SelectValue('//span[contains(@class,"detail-title")]')
    info.Status = dom.SelectValue('//div[contains(@class,"detail-status")]')
    info.Tags = dom.SelectValue('//div[contains(@class,"detail-tags-info")]'):split('/')
    info.Author = dom.SelectValue('//div[contains(@class,"detail-author-name")]'):after(':')
    info.Summary = dom.SelectValue('//div[contains(@class,"detail-description-all")]')

end

function GetChapters()

    for chapterNode in dom.SelectElements('//a[contains(@class,"episode-item")]') do

        local chapterUrl = chapterNode.SelectValue('@href')
        local chapterTitle = chapterNode.SelectValue('.//div[contains(@class,"item-top")]')

        chapters.Add(chapterUrl, chapterTitle)

    end

end

function GetPages()

    -- Some episodes require an account to access, and are "locked".
    -- Don't attempt to download any images if we encounter a locked episode.

    if(isempty(dom.SelectElements('//div[contains(@class,"lock-top-text")]'))) then
        pages.AddRange(dom.SelectValues('//div[contains(@class,"pictures")]//img[not(@class)]/@src'))
    end

end
