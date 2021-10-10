-- This module is for metadata only and cannot download any image content.

function Register()

    module.Name = 'FAKKU!'
    module.Language = 'English'
    module.Adult = true
    module.Type = 'Manga'

    module.Domains.Add('fakku.net')
    module.Domains.Add('www.fakku.net')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Artist = dom.SelectValues('//div[contains(text(),"Artist")]/following-sibling::div/a')
    info.Circle = dom.SelectValues('//div[contains(text(),"Circle")]/following-sibling::div/a')
    info.Parody = dom.SelectValues('//div[contains(text(),"Parody")]/following-sibling::div/a')
    info.Magazine = dom.SelectValues('//div[contains(text(),"Magazine")]/following-sibling::div/a')
    info.Publisher = dom.SelectValues('//div[contains(text(),"Publisher")]/following-sibling::div/a')
    info.Summary = dom.SelectValue('//div[div[contains(@class,"table") and a[contains(@href,"/tags/")]]]/preceding-sibling::div[1]')
    info.Tags = dom.SelectValues('//div[contains(@class,"table")]//a[contains(@href,"/tags/")]')
    info.Status = 'completed'

    info.PageCount = dom.SelectValue('//div[contains(text(),"Pages")]/following-sibling::div'):regex('\\d+')

    if(info.Summary:trim():startswith('Pages')) then
        info.Summary = ''
    end

end
