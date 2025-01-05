function Register()

    module.Name = '漫画スイカ'
    module.Type = 'manga'
    module.Language = 'jp'

    module.Domains.Add('mangasuika.com')
    module.Domains.Add('www.mangasuika.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.AlternativeTitle = dom.SelectValue('//p[contains(.,"代替名")]/following-sibling::p')
    info.Author = dom.SelectValue('//p[contains(.,"著者")]/following-sibling::p')
    info.Status = dom.SelectValue('//p[contains(.,"状態")]/following-sibling::p')
    info.Tags = dom.SelectValue('//p[contains(.,"ジャンル")]/following-sibling::p//a')

end

function GetChapters()
    chapters.AddRange(dom.SelectElements('//div[contains(@class,"list-chapter")]//div[contains(@class,"chapter")]//a'))
end

function GetPages()
    pages.AddRange(dom.SelectValues('//div[contains(@class,"page-chapter")]//img/@src'))
end
