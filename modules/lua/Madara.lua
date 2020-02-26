-- "Madara" is a commonly-used WordPress theme.
-- https://themeforest.net/item/madara-wordpress-theme-for-manga/20849828

function Register()

    module.Name = 'Madara'
    module.Language = 'English'

    module.Domains.Add('disasterscans.com', 'Disaster Scans')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1/text()[last()]')
    info.AlternativeTitle = dom.SelectValue('//div[contains(h5/text(), "Alternative")]/following-sibling::div')
    info.Author = dom.SelectValues('//div[contains(h5/text(), "Author(s)")]/following-sibling::div//a')
    info.Artist = dom.SelectValues('//div[contains(h5/text(), "Artist(s)")]/following-sibling::div//a')
    info.Tags = dom.SelectValues('//div[contains(h5/text(), "Genre(s)")]/following-sibling::div//a')
    info.Type = dom.SelectValue('//div[contains(h5/text(), "Type")]/following-sibling::div')
    info.DateReleased = dom.SelectValue('//div[contains(h5/text(), "Release")]/following-sibling::div')
    info.Status = dom.SelectValue('//div[contains(h5/text(), "Status")]/following-sibling::div')
    info.Summary = dom.SelectValue('//div[contains(@class, "description-summary")]')
    info.Scanlator = 'Disaster Scans'

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//div[contains(@class, "listing-chapters")]//li/a'))

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class, "reading-content")]//img/@data-src'))

end
