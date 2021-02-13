function Register()

    module.Name = 'Epik Manga'
    module.Language = 'Turkish'

    module.Domains.Add('epikmanga.com', 'Epik Manga')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1/text()')
    info.Type = dom.SelectValue('//span[contains(@class, "badge")]')
    info.AlternativeTitle = dom.SelectValue('//strong[contains(text(), "Alternatif İsim")]/following-sibling::text()')
    info.Status = dom.SelectValue('//strong[contains(text(), "Durum")]/following-sibling::text()')
    info.Author = dom.SelectValue('//strong[contains(text(), "Yazar")]/following-sibling::text()')
    info.Artist = dom.SelectValue('//strong[contains(text(), "Çizer")]/following-sibling::text()')
    info.Tags = dom.SelectValues('//strong[contains(text(), "Türler")]/following-sibling::a')
    info.Summary = dom.SelectValues('//h3/following-sibling::p'):join('\n')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//table//a'))

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//img[contains(@class, "chapter-img")]/@src'))

end
