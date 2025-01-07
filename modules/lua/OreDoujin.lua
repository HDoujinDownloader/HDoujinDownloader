-- This site uses a WordPress theme called "novelpops".

function Register()

    module.Name = 'Oredoujin'
    module.Language = 'th'

    module.Domains.Add('oredoujin.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Summary = dom.SelectValue('//div[contains(@class,"entry-content")]')
    info.Tags = dom.SelectValues('//a[contains(@rel,"tag")]')


end

function GetChapters()

    for chapterNode in dom.SelectElements('//div[contains(@class,"eplisterfull")]//a') do

        local chapterUrl = chapterNode.SelectValue('./@href')
        local chapterNumber = chapterNode.SelectValue('./div[contains(@class,"epl-num")]')
        local chapterSubtitle = chapterNode.SelectValue('./div[contains(@class,"epl-title")]')
        local chapterTitle = chapterNumber .. ' ' .. chapterSubtitle

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()
    pages.AddRange(dom.SelectValues('//div[contains(@class,"entry-content")]//img/@src'))
end
