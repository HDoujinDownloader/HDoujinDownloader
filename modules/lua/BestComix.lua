-- "BestComix" is a WordPress theme used by western comic websites.

require "WordPress"

local BaseGetInfo = GetInfo

WORDPRESS_THEME = "bestcomix"

function Register()

    module.Name = 'BestComix'
    module.Adult = true
    module.Language = 'en'

    module.Domains.Add('bestporncomix.com', 'Porn Comics')
    module.Domains.Add('*')

end

function GetInfo()

    BaseGetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Tags = dom.SelectValues('//p[contains(@class,"entry-tags")]//a')

end

function GetPages()
    pages.AddRange(dom.SelectValues('//figure[contains(@class,"jg-item")]//a/@href'))
end
