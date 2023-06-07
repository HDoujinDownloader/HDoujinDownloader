-- Foxiz is a WordPress theme.
-- https://themeforest.net/item/foxiz-wordpress-newspaper-and-magazine/34617430

function Register()

    module.Name = 'Foxiz'
    
    module.Domains.Add('fsicomics.com', 'FSI Comics')

end

function GetInfo()
    
    info.Title = dom.SelectValue('//h1')
    info.Summary = dom.SelectValue('//div[contains(@class,"entry-content")]/p')
    info.Tags = dom.SelectValues('//a[@rel="tag"]')

end

function GetPages()

    pages.AddRange(dom.SelectValues('//figure[contains(@class,"wp-block-image")]//a/@href'))

end
