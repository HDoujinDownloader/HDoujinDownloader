function Register()

    module.Name = 'MangaHasu'
    module.Language = 'en'
    module.Adult = false

    module.Domains.Add('mangahasu.com')
    module.Domains.Add('mangahasu.se')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.AlternativeTitle = dom.SelectValue('//div[contains(@class,"info-title")]/h3')
    info.Author = dom.SelectValues('//b[contains(text(),"Author(s)")]/following-sibling::span//a')
    info.Artist = dom.SelectValues('//b[contains(text(),"Artist(s)")]/following-sibling::span//a')
    info.Type = dom.SelectValue('//b[contains(text(),"Type")]/following-sibling::span//a')
    info.Tags = dom.SelectValues('//b[contains(text(),"Genre(s)")]/following-sibling::span//a')
    info.Status = dom.SelectValue('//b[contains(text(),"Status")]/following-sibling::span//a')
    info.Summary = dom.SelectValue('//h3[contains(text(),"Summary")]/following-sibling::*')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//div[contains(@class,"list-chapter")]//a'))

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//img[contains(@class,"page")]/@data-src'))

end
