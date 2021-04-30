require "LoveHeaven"

function Register()

    module.Name = 'TruyentranhLH'
    module.Language = 'Vietnamese'
    module.Adult = false

    module.Domains.Add('truyentranhlh.net')

end

function GetInfo()

    info.Title = dom.SelectValue('//span[contains(@class,"series-name")]')
    info.AlternativeTitle = dom.SelectValue('//span[contains(text(),"Tên khác")]/following-sibling::span')
    info.Author = dom.SelectValue('//span[contains(text(),"Tác giả")]/following-sibling::span')
    info.Status = dom.SelectValue('//span[contains(text(),"Tình trạng")]/following-sibling::span')
    info.Summary = dom.SelectValue('//div[contains(@class,"summary-content")]')

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[@id="chapter-content"]//img/@data-src'))

end
