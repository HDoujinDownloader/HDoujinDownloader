
-- "boxtruyen" is a WordPress theme used predominantly on Vietnamese websites.
-- https://themesinfo.com/theme-wordpress-boxtruyen-bcbb8

function Register()

    module.Name = 'BoxTruyen'
    module.Language = 'Vietnamese'
    module.Adult = true
    
    module.Domains.Add('hentai24h.org', 'HENTAIME.NET')
    module.Domains.Add('hentaime.net', 'HENTAIME.NET')

end

function GetInfo()

    info.Title = dom.SelectValue('//h2')
    info.Summary = dom.SelectValue('//div[contains(@class, "desc-text")]')
    info.Author = dom.SelectValue('//h3[contains(text(),"Tác giả")]/following-sibling::text()')
    info.Tags = dom.SelectValues('//h3[contains(text(),"Thể loại")]/following-sibling::span/a')
    info.Status = dom.SelectValue('//h3[contains(text(),"Trạng thái")]/following-sibling::span')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//div[contains(@class,"l-chapter")]//a'))

    chapters.Reverse()

end

function GetPages()

    for pageUrl in dom.SelectValues('//div[contains(@class,"chapter-content")]//img/@src') do
        pages.Add(pageUrl)
    end

end
