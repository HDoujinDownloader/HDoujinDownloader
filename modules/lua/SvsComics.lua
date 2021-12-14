function Register()

    module.Name = 'SVSComics'
    module.Adult = true

    module.Domains.Add('svscomics.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//title')
    info.Tags = dom.SelectValues('//div[contains(@class,"tagzfull")]//a')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//h2[contains(@class,"info-full") and contains(.,"CHAPTERS")]//a/@href'))

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"prevgallery")]//a/@href'))

end
