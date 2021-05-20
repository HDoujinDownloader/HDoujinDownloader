require "EarlyManga"

function Register()

    module.Name = 'MangaDexTv'
    module.Language  = 'English'

    module.Domains.Add('mangadex.tv', 'MangaDex')

end

function GetChapters()
    
    chapters.AddRange(dom.SelectElements('//div[contains(@class,"chapter-row")]//a'))

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"reader-images")]//img/@data-src'))

end
