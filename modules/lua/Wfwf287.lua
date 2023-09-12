function Register()

    module.Name = '늑대닷컴'
    module.Language = 'kr'

    module.Domains.Add('wfwf287.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Tags = dom.SelectValue('//strong[contains(text(),"장르")]/following-sibling::text()')
    info.Summary = dom.SelectValue('//div[contains(@class,"txt")]')

end

function GetChapters()

    for chapterNode in dom.SelectElements('//div[contains(@class,"bbs-list")]//ul[1]//a') do

        local chapterUrl = chapterNode.SelectValue('./@href')
        local chapterTitle = chapterNode.SelectValue('.//div[contains(@class,"subject")]/text()[1]')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"image-view")]//img/@data-original'))

    pages.Referer = GetRoot(url)

end
