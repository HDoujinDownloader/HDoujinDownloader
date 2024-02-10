function Register()

    module.Domains.Add('hentai.name')
    module.Domains.Add('www.hentai.name')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Tags = dom.SelectValues('//div[contains(text(),"Tags")]/span[contains(@class,"tags")]//a/text()[1]')
    info.Artist = dom.SelectValues('//div[contains(text(),"Artists")]/span[contains(@class,"tags")]//a/text()[1]')
    info.Language = dom.SelectValues('//div[contains(text(),"Languages")]/span[contains(@class,"tags")]//a/text()[1]')

end

function GetPages()

    local thumbnailUrls = dom.SelectValues('//a[contains(@class,"gallerythumb")]//img/@data-src')

    if(isempty(thumbnailUrls)) then
        thumbnailUrls = dom.SelectValues('//a[contains(@class,"gallerythumb")]//img/@src')
    end

    for thumbnailUrl in thumbnailUrls do

        local imageUrl = thumbnailUrl:replace('_thumb', '')

        pages.Add(imageUrl)

    end

end
