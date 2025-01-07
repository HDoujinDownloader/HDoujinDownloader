function Register()

    module.Name = 'MangaBR'
    module.Language = 'pt-br'

    module.Domains.Add('mangabr.net')

end

function GetInfo()

    info.Title = dom.SelectValue('(//h1)[2]')
    info.Summary = dom.SelectValue('//h5[contains(text(),"Resumo")]/following-sibling::p')

end

function GetChapters()

    for chapterNode in dom.SelectElements('//div[contains(@class,"chapters-list")]//a') do

        local chapterUrl = chapterNode.SelectValue('./@href')
        local chapterTitle = chapterNode.SelectValue('.//h5/text()[1]')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    for page in Paginator.New(http, dom, '//a[contains(@class,"btn-next")]/@href') do
        pages.AddRange(page.SelectValues('//div[contains(@class,"book-page")]//img/@src'))
    end

end
