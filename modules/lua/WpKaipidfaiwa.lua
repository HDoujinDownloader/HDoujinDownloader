require "WpMangaReader"

local BaseGetInfo = GetInfo
local BaseGetPages = GetPages

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

function GetPages()

    BaseGetPages()

    -- If this specific referer string isn't used, we'll get redirected to the homepage.
    -- Furthermore, the images will refuse to load from the current IP address (i.e. inaccessible from browser too).

    pages.Referer = 'https://' .. GetDomain(url) .. '/'

end
