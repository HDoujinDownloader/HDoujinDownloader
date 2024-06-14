-- This site uses the same reader as Ahentai.

require "Ahentai"

function Register()

    module.Name = 'Ahri Gallery'
    module.Adult = true

    module.Domains.Add('04rfcvkubizd0405.top')

end

function GetInfo()

    info.Title = dom.SelectValue('//div[contains(@class,"gallery_title2")]')
    info.Language = dom.SelectValues('//td[contains(text(),"language:")]/following-sibling::td//a')
    info.Artist = dom.SelectValues('//td[contains(text(),"artist:")]/following-sibling::td//a')
    info.Tags = dom.SelectValues('//table//div[contains(@class,"tag")]')
    info.Type = dom.SelectValue('(//a[contains(@class,"btn-warning")])[2]')

    if(isempty(info.Title)) then
        info.Title = dom.SelectValue('//h1')
    end

    -- Adjust the URL so that it's pointed at the reader.

    info.Url = dom.SelectValue('//div[contains(@class,"action_btn")]//a/@href')

end
