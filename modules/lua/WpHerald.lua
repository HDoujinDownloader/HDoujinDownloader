-- Herald is a WordPress theme.
-- https://themeforest.net/item/herald-news-portal-magazine-wordpress-theme/13800118

function Register()

    module.Name = 'Herald'
    module.Adult = true

    module.Domains.Add('yaoimangaonline.com', 'Yaoi Manga Online')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Summary = dom.SelectValue('//div[contains(@class,"entry-content")]/p')
    info.Author = info.Summary:regex('Author:\\s*([^\\s]+)', 1)
    info.Artist = info.Summary:regex('Mangaka:\\s*([^\\s]+)', 1)
    info.Language = info.Summary:regex('Language:\\s*([^\\s]+)', 1)
    info.Tags = dom.SelectValues('//div[contains(@class,"meta-tags")]//a')
    info.Type = info.Summary:regex('(Doujinshi|Manga):', 1)
    info.AlternativeTitle = info.Summary:regex('(?:Doujinshi|Manga):\\s*(.+?)\n', 1):split(';')

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"entry-content")]//img/@src'))

end
