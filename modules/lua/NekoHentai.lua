function Register()

    module.Name = 'Neko Hentai'
    module.Language = 'Thai'
    module.Adult = true

    module.Domains.Add('neko-hentai.net')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Type = dom.SelectValues('//div[contains(text(),"หมวดหมู่")]/following-sibling::div//a')
    info.DateReleased = dom.SelectValues('//div[contains(text(),"เผยแพร่ครั้งแรกปี")]/following-sibling::div//a')
    info.Artist = dom.SelectValues('//div[contains(text(),"ศิลปิน")]/following-sibling::div//a')
    info.Tags = dom.SelectValues('//div[contains(text(),"ประเภท")]/following-sibling::div//a')

end

function GetChapters()
    chapters.AddRange(dom.SelectElements('//div[contains(@class,"ep-row")]//a'))
end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@id,"manga-content")]//img/@data-src'))

    if(isempty(pages)) then
        pages.AddRange(dom.SelectValues('//div[contains(@id,"manga-content")]//img/@src'))
    end

end
