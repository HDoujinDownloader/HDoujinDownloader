function Register()

    module.Name = 'Meow Scan'
    module.Language = 'Spanish'

    module.Domains.Add('meowscannew.blogspot.com')

end

function GetInfo()

    local summaryContent = dom.SelectValue('//div[contains(@class,"MsoNormal")]')

    info.Title = dom.SelectValue('//h3[contains(@class,"post-title")]')
    info.Author = summaryContent:regex('MANGAKA:(?:&nbsp;)+([^&]+)', 1)
    info.Summary = summaryContent:regex('SINOPSIS:([^&]+)', 1)
    info.Tags = dom.SelectValues('//div[contains(@class,"post-footer")]//a[@rel="tag"]')
    info.Scanlator = module.Name

end

function GetChapters()

    -- Chapter URLs look very similar to image URLs, so be careful.
    -- See https://github.com/HDoujinDownloader/HDoujinDownloader/issues/96
    -- Since the links are just images, we'll use the post title as the title.

    local chapterTitle = dom.SelectValue('//h3[contains(@class,"post-title")]')

    for chapterUrl in dom.SelectValues('//div[contains(@class,"separator")]//a[contains(@href,".html")]/@href') do

        chapters.Add(chapterUrl, chapterTitle)

    end

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"separator")]//img/@src'))

end
