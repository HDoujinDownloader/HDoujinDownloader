require "WpMangaReader"

local BaseGetInfo = GetInfo

function Register()

    module.Language = 'Thai'

    module.Domains.Add('manga168.com', 'Manga168')

end

function GetInfo()

    BaseGetInfo()

    info.Status = dom.SelectValue('//td[contains(text(),"สถานะ")]/following-sibling::td')
    info.Type = dom.SelectValue('//td[contains(text(),"ประเภท")]/following-sibling::td')
    info.Tags = dom.SelectValues('//div[contains(@class,"seriestugenre")]/a')

end
