function Register()
    module.Name = "NyaHentai"
    module.Language = "jp"
    module.Adult = true

    module.Domains:Add("nyahentai.re")
end

function GetInfo()
    info.Title = dom.SelectValue('//h1')
    info.Tags = dom.SelectValues('//div[contains(@id,"post-tag")]//a')
end

function GetPages()
    pages.AddRange(dom.SelectValues('//div[contains(@id,"post-comic")]//img/@src'))
end
