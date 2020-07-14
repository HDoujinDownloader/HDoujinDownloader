-- PT Magazine is a WordPress theme.
-- https://wordpress.org/themes/pt-magazine/

function Register()

    module.Name = 'PT Magazine'
    module.Language = 'Japanese'
    module.Type = 'Manga'

    module.Domains.Add('manga1000.com', 'Manga Raw')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Tags = dom.SelectValues('//span[contains(@class,"tags")]/a')
    info.Summary = dom.SelectValue('//p[2]')
    info.AlternativeTitle = dom.SelectValue('//strong[contains(text(),"OTHER NAMES")]/following-sibling::text()')
    info.Author = dom.SelectValue('//strong[contains(text(),"作者")]/following-sibling::text()')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//div[contains(@class,"chaplist")]//a'))

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"entry-content")]//img/@src'))

end
