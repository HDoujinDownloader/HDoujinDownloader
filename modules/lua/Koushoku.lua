function Register()

    module.Name = 'Koushoku'
    module.Language = 'en'
    module.Adult = true

    module.Domains.Add('koushoku.org')

end

function GetInfo()

    if(IsTagUrl()) then

        EnqueueAllGalleries()

    else

        info.Title = dom.SelectValue('//h1')
        info.Artist = dom.SelectValues('//tr[contains(@class,"artists")]//a')
        info.Tags = dom.SelectValues('//tr[contains(@class,"tags")]//a')

    end

end

function GetPages()

    local permalinkUrls = dom.SelectValues('//div[contains(@class,"preview")]//a/@href')

    pages.AddRange(permalinkUrls)

end

function BeforeDownloadPage()

    if(page.Url:contains('/archive/')) then

        page.Url = dom.SelectValue('//img/@src')

    end

end

function IsTagUrl()

    return not url:contains('/archive/')

end

function EnqueueAllGalleries()

    for page in Paginator.New(http, dom, '//nav[contains(@class,"pagination")]//li[a[contains(@class,"active")]]/following-sibling::li/a/@href') do

        local galleryUrls = page.SelectValues('//article[contains(@class,"entry")]/a/@href')

        for i = 0, galleryUrls.Count() - 1 do
            Enqueue(galleryUrls[i])
        end
        
    end

    info.Ignore = true

end
