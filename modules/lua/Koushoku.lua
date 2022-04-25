function Register()

    module.Name = 'Koushoku'
    module.Language = 'en'
    module.Adult = true

    module.Domains.Add('koushoku.org')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Artist = dom.SelectValues('//tr[contains(@class,"artists")]//a')
    info.Tags = dom.SelectValues('//tr[contains(@class,"tags")]//a')

end

function GetPages()

    local thumbnailUrls = dom.SelectValues('//div[contains(@class,"preview")]//img/@src')

    for thumbnailUrl in thumbnailUrls do

        local baseImageUrl = thumbnailUrl:beforelast('/')

        local page = PageInfo.New()

        -- Do we have to worry about other file extensions?

        page.Url = baseImageUrl .. '.jpg'
        page.BackupUrls.Add(baseImageUrl .. '.png')

        pages.Add(page)

    end

end
