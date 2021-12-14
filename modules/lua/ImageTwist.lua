function Register()

    module.Name = 'ImageTwist'

    module.Domains.Add('imagetwist.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//img[contains(@class,"pic")]/@alt')

end

function GetPages()

    pages.Add(url)

end

function BeforeDownloadPage()

    -- Ignore direct image URLs.

    if(GetHost(page.Url) == module.Domain) then

        page.Referer = page.Url
        page.Url = dom.SelectValue('//img[contains(@class,"pic")]/@src')

    end

end
