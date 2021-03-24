function Register()
   
    module.Name = 'NhatTruyen'
    module.Language = 'Vietnamese'

    module.Domains.Add('nettruyen.com', 'NetTruyen')
    module.Domains.Add('nhattruyen.com', 'NhatTruyen')
    
end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Author = dom.SelectValue('//p[contains(.,"Tác giả")]/following-sibling::p')
    info.Tags = dom.SelectValues('//p[contains(.,"Thể loại")]/following-sibling::p//a')
    info.Summary = dom.SelectValue('//div[contains(@class,"detail-content")]//p')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//div[@id="nt_listchapter"]//div[contains(@class,"chapter")]/a'))

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@id,"page_")]/img/@data-original'))

end
