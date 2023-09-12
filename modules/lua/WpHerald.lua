-- Herald is a WordPress theme.
-- https://themeforest.net/item/herald-news-portal-magazine-wordpress-theme/13800118

function Register()

    module.Name = 'Herald'
    module.Adult = true

    module.Domains.Add('mangalotus.com', 'Manga Lotus')
    module.Domains.Add('yaoidj.com', 'Yaoi DJ')
    module.Domains.Add('yaoimangaonline.com', 'Yaoi Manga Online')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Summary = dom.SelectValue('//div[contains(@class,"entry-content")]/p')
    info.Author = info.Summary:regex('(?m)Author:\\s([^\n]+)', 1)
    info.Artist = info.Summary:regex('(?m)Mangaka:\\s([^\n]+)', 1)
    info.Language = info.Summary:regex('Language:\\s([^\n]+)', 1)
    info.Tags = dom.SelectValues('//div[contains(@class,"meta-tags")]//a')
    info.Type = info.Summary:regex('(Doujinshi|Manga):', 1)
    info.AlternativeTitle = info.Summary:regex('(?:Doujinshi|Manga):\\s*(.+?)\n', 1):split(';')

end

function GetChapters()

    -- All posts will list chapters (if applicable), but "Intro" posts don't have images.
    -- We'll only list the chapters if an "Intro" post has been added.

    if(GetImageUrls().Count() <= 0) then
        
        chapters.AddRange(dom.SelectElements('//nav[contains(@class,"mpp-toc")]//a'))
        
    end

end

function GetPages()

    pages.AddRange(GetImageUrls())

end

function GetImageUrls()

    return dom.SelectValues('//div[contains(@class,"entry-content")]//img/@src')

end
