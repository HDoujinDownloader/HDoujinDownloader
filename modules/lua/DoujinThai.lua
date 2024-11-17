function Register()

    module.Name = 'Doujin-THAI'
    module.Adult = true
    module.Language = 'Thai'

    module.Domains.Add('hxani.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1'):beforelast(' - ')
    info.Translator = dom.SelectValue('//div[contains(@class,"watch-detail")]'):regex('translation by:\\s*([^\n]+)', 1)
    info.Tags = dom.SelectValues('//div[contains(@class,"watch-detail")]//a[contains(@class,"badge")]')

end

function GetPages()
    pages.AddRange(dom.SelectValues('//div[contains(@id,"hdoujin")]//img/@data-src'))
end
