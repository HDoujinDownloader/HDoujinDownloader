--  A WordPress theme named "Blossom Diva": https://blossomthemes.com/
-- Sites using this theme may have a footer containing the text "Blossom Diva".

function Register()

    module.Name = 'Blossom Diva'
    module.Language = 'en'
    module.Adult = true

    module.Domains.Add('hentaiporns.net', 'Hentai porns')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Tags = dom.SelectValues('//a[contains(@rel,"tag")]')

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"portrait")]/a/@href'))

end
