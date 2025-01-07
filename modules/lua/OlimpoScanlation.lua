require 'Manhua18'

local BaseGetInfo = GetInfo

function Register()

    module.Name = 'Olimpo Scanlation'
    module.Language = 'Spanish'

    module.Domains.Add('leerolimpo.com', 'Olimpo Scanlation')

end

function GetInfo()

    BaseGetInfo()

    info.Title = dom.SelectValue('//ul[contains(@class,"manga-info")]//h3')
    info.AlternativeTitle = dom.SelectValue('//li[contains(.,"Otros nombres")]/text()[last()]'):after(':')
    info.Tags = dom.SelectValues('//b[contains(.,"Género(s)")]/following-sibling::a')
    info.Status = dom.SelectValue('//b[contains(.,"Estado")]/following-sibling::a')
    info.Scanlator = dom.SelectValue('//b[contains(text(),"traducción")]/following-sibling::a')

    if(info.Title:contains('- BR')) then
        info.Language = 'pt-br'
    end

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"chapter-content")]//img/@data-original'))

    for page in pages do

        -- From function.js

        if(page.Url:contains('&site=')) then
            page.Url = '/image.c?link=' .. page.Url
        end

    end

end
