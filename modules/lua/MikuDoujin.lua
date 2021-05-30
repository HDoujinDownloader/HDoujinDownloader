function Register()

    module.Name = 'Miku-Doujin'
    module.Language = 'Thai'
    module.Adult = true

    module.Domains.Add('miku-doujin.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//div[contains(@class,"card-header")]')
    info.Circle = dom.SelectValues('//small[contains(text(),"หมวดหมู่")]/a')
    info.Type = dom.SelectValues('//small[contains(text(),"เรื่อง")]/a')
    info.Artist = dom.SelectValues('//small[contains(text(),"ผู้วาด")]/a')
    info.Language = dom.SelectValues('//small[contains(text(),"ภาษา")]/a')
    info.Characters = dom.SelectValues('//p[contains(.,"ตัวละคร")]//a')
    info.Tags = dom.SelectValues('//p[contains(.,"ประเภท")]//a')

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[@id="manga-content"]/img/@data-src'))

end
