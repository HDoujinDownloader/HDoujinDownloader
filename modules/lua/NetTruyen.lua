function Register()

    module.Name = 'NetTruyen'
    module.Language = 'vn'

    module.Domains.Add('nettruyen.com')
    module.Domains.Add('nettruyenme.com')
    module.Domains.Add('nettruyenmoi.com')
    module.Domains.Add('nettruyenone.com')
    module.Domains.Add('www.nettruyen.com')
    module.Domains.Add('www.nettruyenme.com')
    module.Domains.Add('www.nettruyenmoi.com')
    module.Domains.Add('www.nettruyenone.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Author = dom.SelectValues('//p[contains(.,"Tác giả")]/following-sibling::p//a')
    info.Status = dom.SelectValue('//p[contains(.,"Tình trạng")]/following-sibling::p')
    info.Tags = dom.SelectValues('//p[contains(.,"Thể loại")]/following-sibling::p//a')
    info.Summary = dom.SelectValue('//div[contains(@class,"detail-content")]//p')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//div[contains(@class,"chapter")]/a'))

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@id,"page_")]/img/@data-original'))

end
