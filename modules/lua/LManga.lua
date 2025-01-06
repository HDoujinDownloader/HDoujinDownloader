function Register()

    module.Name = 'L漫画'
    module.Language = 'jp'
    module.Adult = false
    module.Type = 'manga'

    module.Domains.Add('lmanga.com')
    module.Domains.Add('www.lmanga.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.AlternativeTitle = dom.SelectValue('//span[contains(.,"ほかの名前")]/following-sibling::text()')
    info.Artist = dom.SelectValue('//span[contains(.,"著者")]/following-sibling::text()'):split('/')
    info.Tags = dom.SelectValues('//span[contains(.,"ジャンル")]/following-sibling::a')
    info.Summary = dom.SelectValue('//span[contains(.,"説明")]/following-sibling::div')

end

function GetChapters()

    for chapterNode in dom.SelectElements('//a[contains(@class,"ChapterLink")]') do

        local chapterUrl = chapterNode.SelectValue('./@href')
        local chapterTitle = chapterNode.SelectValue('./span[1]')

        chapters.Add(chapterUrl, chapterTitle)

    end

end

function GetPages()
    pages.AddRange(dom.SelectValues('//div[contains(@class,"ImageGallery")]//img/@data-original'))
end
