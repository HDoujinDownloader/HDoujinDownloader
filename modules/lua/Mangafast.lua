function Register()

    module.Name = 'Mangafast'

    module.Domains.Add('mangafast.net')

end

function GetInfo()

    info.Title = dom.SelectValue('//td[contains(text(),"Title")]/following-sibling::td')
    info.AlternativeTitle = dom.SelectValue('//td[contains(text(),"Alternative")]/following-sibling::td')
    info.Author = dom.SelectValue('//td[contains(text(),"Author")]/following-sibling::td')
    info.Language = dom.SelectValue('//td[contains(text(),"Language")]/following-sibling::td')
    info.Status = dom.SelectValue('//td[contains(text(),"Status")]/following-sibling::td')
    info.Tags = dom.SelectValues('//td[contains(text(),"Genres")]/following-sibling::td//a')
    info.Summary = dom.SelectValues('//h2[contains(@id,"Synopsis")]/following-sibling::p[not(a)]'):join('\n')
    info.Type = dom.SelectValue('//h1'):trim():regex('(Manhwa|Manhua|Manga)$', 1)

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//tr[@itemprop="hasPart" and not(.//td[contains(text(),"Scheduled")])]/td[1]/a'))

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[@id="Read"]//img/@src'))

end
