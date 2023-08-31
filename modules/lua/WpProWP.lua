-- ProWP is a WordPress theme.
-- https://wordpress.org/themes/prowp/

function Register()

    module.Name = 'ProWP'
    module.Language = 'en'

    module.Domains.Add('comicsporno.tv', 'Comics porno')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@id,"gallery")]//img/@data-src'))

end
