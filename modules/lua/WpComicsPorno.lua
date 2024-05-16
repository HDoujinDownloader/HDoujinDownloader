function Register()

    module.Name = 'ComicsPorno'
    module.Adult = true
    module.Language = 'en'

    module.Domains.Add('hdporncomics.com', 'HD Porn Comics')

end

local function CleanTitle(title)

    return RegexReplace(tostring(title), '(?i)comic porn$', '')

end

function GetInfo()

    info.Title = CleanTitle(dom.SelectValue('//h1'))
    info.Artist = dom.SelectValues('//span[contains(text(), "Artist")]/following-sibling::span//a')
    info.Tags = dom.SelectValues('//span[contains(text(), "Tags")]/following-sibling::span//a')
    info.Summary = dom.SelectValue('//div[contains(@id,"summary")]')

end

function GetChapters()

    -- Note that not all galleries have chapters.

    chapters.AddRange(dom.SelectElements('//div[contains(@id,"allChapters")]//a'))

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"my-gallery")]//a/@href'))

    -- Get images from the reader.

    if(isempty(pages)) then
        pages.AddRange(dom.SelectValues('//div[contains(@id,"imageContainer")]//img/@src'))
    end

end
