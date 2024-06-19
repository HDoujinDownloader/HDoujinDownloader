function Register()

    module.Name = 'Mode Scanlator'
    module.Language = 'Portuguese'

    module.Domains.Add('modescanlator.com')

end

local function GetChapterCount()
    return dom.SelectValue('//span[contains(text(),"Total chapters")]/following-sibling::span')
end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Status = dom.SelectValue('//span[contains(@class,"rounded uppercase")]')
    info.Summary = dom.SelectValue('//div[contains(@class,"text-muted-foreground")]')
    info.DateReleased = dom.SelectValue('//span[contains(text(),"Release year")]/following-sibling::span')
    info.Author = dom.SelectValue('//span[contains(text(),"Author")]/following-sibling::span')
    info.ChapterCount = GetChapterCount()
end

function GetChapters()

    local slug = url:regex('\\/series\\/([^\\/?#]+)', 1)

    for i = 1, GetChapterCount() do

        local chapterTitle = 'Capítulo ' .. string.format("%02d", i)
        local chapterUrl = '/series/' .. slug .. '/capitulo-' .. string.format("%02d", i)

        chapters.Add(chapterUrl, chapterTitle)
        
    end

end

function GetPages()
    pages.AddRange(dom.SelectValues('//div[contains(@class,"items-center")]//img[@data-src]/@src'))
end
