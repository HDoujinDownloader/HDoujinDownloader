require 'EarlyManga'

local GetInfoBase = GetInfo

function Register()

    module.Name = 'MangaDexTv'
    module.Language  = 'English'

    module.Domains.Add('mangadex.tv', 'MangaDex')

end

function GetInfo()

    GetInfoBase()

    if(isempty(info.Title)) then
        info.Title = CleanTitle(dom.Title)
    end

end

function GetChapters()
    
    chapters.AddRange(dom.SelectElements('//div[contains(@class,"chapter-row")]//a'))

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"reader-images")]//img/@data-src'))

end

function CleanTitle(title)

    title = tostring(title):trim()
    title = RegexReplace(title, '^Read\\s|\\s-\\sMangadex$', '')

    return title

end
