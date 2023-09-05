function Register()

    module.Name = '包子漫畫'
    module.Language = 'chinese'

    module.Domains.Add('baozimh.com')
    module.Domains.Add('www.baozimh.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1[contains(@class,"comics-detail__title")]')
    info.Author = dom.SelectValue('//h2[contains(@class,"comics-detail__author")]')
    info.Tags = dom.SelectValues('//div[contains(@class,"tag")]//span')
    info.Summary = dom.SelectValue('//p')

    -- Added from reader

    if(isempty(info.Title)) then
        info.Title = dom.SelectValue('//span[contains(@class,"title")]')
    end

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//div[contains(@id,"chapter-items") or contains(@id,"chapters_other_list")]//a'))

end

function GetPages()

    for jsonStr in dom.SelectValues('//amp-state[contains(@id,"chapter")]//script/text()') do

        local pageUrl = Json.New(jsonStr).SelectValue('url')

        pages.Add(pageUrl)

    end

end
