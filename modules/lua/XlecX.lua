function Register()

    module.Name = 'XlecX.org'
    module.Adult = true

    module.Domains.Add('xlecx.org', 'XlecX.org')

end

function GetInfo() 

    info.Title = dom.SelectValue('//h1')
    info.Circle = dom.SelectValues('//div[contains(text(), "Group:")]/a')
    info.Artist = dom.SelectValues('//div[contains(text(), "Artist:")]/a')
    info.Parody = dom.SelectValues('//div[contains(text(), "Parody:")]/a')
    info.Tags = dom.SelectValues('//div[contains(text(), "Tags:")]/a')

end

function GetPages()

    -- The reader is a little bit inconsistent, so we need to try different things to get the images.

    pages.AddRange(dom.SelectValues('//div[contains(@class, "full-text")]//a/@href'))

    if(pages.Count() <= 0) then
        pages.AddRange(dom.SelectValues('//div[contains(@class, "full-text")]//img/@data-src'))
    end

end
