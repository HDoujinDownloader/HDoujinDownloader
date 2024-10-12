function Register()

    module.Name = '漫画時間'
    module.Language = 'Japanese'
    module.Type = 'Manga'

    module.Domains.Add('mangajikan.com')
    module.Domains.Add('www.mangajikan.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h2')
    info.AlternativeTitle = dom.SelectValue('//span[contains(text(),"エイリアス")]'):after('：')
    info.Tags = dom.SelectValues('//span[contains(text(),"タグ")]//a')
    info.DateReleased = dom.SelectValue('//span[contains(text(),"年代")]'):after('：')
    info.Summary = dom.SelectValue('//div[contains(text(),"まとめ")]'):after('：')

end

function GetChapters()
    chapters.AddRange(dom.SelectElements('//div[contains(@class,"episode-box")]//a'))
end

function GetPages()
    pages.AddRange(dom.SelectValues('//li[contains(@class,"img")]//img/@src'))
end
