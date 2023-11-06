function Register()

    module.Name = 'YugenMangas'
    module.Language = 'es'

    module.Domains.Add('yugenmangas.com')
    module.Domains.Add('yugenmangas.lat')
    module.Domains.Add('yugenmangas.net')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.AlternativeTitle = dom.SelectValue('//h1/following-sibling::p'):split('/')
    info.Summary = dom.SelectValue('//h5[contains(text(),"Description")]/following-sibling::div')
    info.Author = dom.SelectValue('//p[contains(text(),"Autor:")]//strong')
    info.DateReleased = dom.SelectValue('//p[contains(text(),"Ano de lançamento")]//strong')

end

function GetChapters()

    for chapterNode in dom.SelectElements('//ul[contains(@class,"grid")]//a') do

        local chapterUrl = chapterNode.SelectValue('./@href')
        local chapterTitle = chapterNode.SelectValue('.//span')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    for imageNode in dom.SelectElements('//div[contains(@class,"container")]//p//img') do
        
        local srcUrl = imageNode.SelectValue('./@src')
        local dataSrcUrl = imageNode.SelectValue('./@data-src')

        if(not isempty(srcUrl)) then
            pages.Add(srcUrl)
        elseif(not isempty(dataSrcUrl)) then
            pages.Add(dataSrcUrl)
        end

    end

end
