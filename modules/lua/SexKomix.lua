function Register()

    module.Name = 'Sex Komix'
    module.Adult = true
    
    module.Domains.Add('sexkomix2.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//div[contains(@id,"comix_description")]//h1')
    info.Author = dom.SelectValues('//div[contains(@class,"studio_translator")]//a')
    info.Tags = dom.SelectValues('//div[contains(text(),"Categories") or contains(text(),"Tags")]//a')
    info.Summary = dom.SelectValue('//div[contains(text(),"Description")]//p') 

end

function GetPages()

    -- Some images appear in the list twice, 

    pages.AddRange(dom.SelectValues('//ul[contains(@id,"comix_pages_ul")]//img[@alt]/@data-src'))

end
