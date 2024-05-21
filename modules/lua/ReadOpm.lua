-- This module is for a network of similar websites where each one is dedicated to a specific title.
-- I wasn't sure what to call it, but the "Contact Us" link leads to readopm.com.

function Register()

    module.Name = 'ReadOpm'

    module.Domains.Add('readsnk.com', 'READ ATTACK ON TITAN/SHINGEKI NO KYOJIN MANGA')

end

local function CleanTitle(title)

    return RegexReplace(title, '(?i)(?:^Read|Manga$)', '')

end

function GetInfo()

    info.Title = CleanTitle(dom.SelectValue('(//h1)[last()]'))
    info.Summary = dom.SelectValue('//div[text()="Description"]/following-sibling::div')
    
end

function GetChapters()

    local chapterNodes = dom.SelectElements('//div[contains(@class,"w-full")]//div[a[contains(@class,"text-lg")]]')

    for chapterNode in chapterNodes do

        local chapterUrl = chapterNode.SelectValue('a/@href')
        local chapterTitle = chapterNode.SelectValue('a')
        local subtitle = chapterNode.SelectValue('div')

        if(not isempty(subtitle)) then
            chapterTitle = chapterTitle .. ' - ' ..  subtitle
        end

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"pages-container")]//img/@src'))

end
