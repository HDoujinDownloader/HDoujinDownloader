function Register()

    module.Name = 'ComicsPorno'
    module.Adult = true
    module.Language = 'en'

    module.Domains.Add('hdporncomics.com', 'HD Porn Comics')

end

function GetInfo()

    info.Title = CleanTitle(dom.SelectValue('//h1'))
    info.Artist = dom.SelectValues('//span[contains(text(), "Artist")]/following-sibling::span//a')
    info.Tags = dom.SelectValues('//span[contains(text(), "Tags")]/following-sibling::span//a')

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"my-gallery")]//a/@href'))

end

function CleanTitle(title)

    return RegexReplace(tostring(title), '(?i)comic porn$', '')

end
