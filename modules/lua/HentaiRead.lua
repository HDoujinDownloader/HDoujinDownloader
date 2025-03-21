-- HentaiRead uses a customized version of the Madara theme that shows page thumbnails instead of chapters.

function Register()

    module.Name = 'HentaiRead'
    module.Language = 'en'
    module.Adult = true

    module.Domains.Add('hentairead.com')

end

local function EnqueueAllGalleries(dom)

    for galleryUrl in dom.SelectValues('//div[contains(@class,"manga-grid")]//h3/a[contains(@href,"/hentai/")]/@href') do
        Enqueue(galleryUrl)
    end

end

function GetInfo()

    if(url:contains('/hentai/')) then

        info.Title = dom.SelectValue('//h1')
        info.OriginalTitle = dom.SelectValue('//h2')
        info.Artist = dom.SelectValues('//div[contains(text(),"Artist")]/following-sibling::a/span[1]')
        info.Language = dom.SelectValues('//div[contains(text(),"Language")]/following-sibling::a/span[1]')
        info.Type = dom.SelectValues('//div[contains(text(),"Category")]/following-sibling::a/span[1]')
        info.Circle = dom.SelectValues('//div[contains(text(),"Circle")]/following-sibling::a/span[1]')
        info.Parody = dom.SelectValues('//div[contains(text(),"Parody")]/following-sibling::a/span[1]')
        info.Tags = dom.SelectValues('//div[contains(text(),"Tags")]/following-sibling::a/span[1]')
        info.Scanlator = dom.SelectValues('//div[contains(text(),"Scanlator")]/following-sibling::a/span[1]')
        info.DateReleased = dom.SelectValues('//div[contains(text(),"Release Year")]/following-sibling::a/span[1]')

    else

        -- Add all collection entries separately.

        info.Ignore = true

        local maxScrapingDepth = global.GetSetting('Downloads.MaxScrapingDepth')

        if(isempty(maxScrapingDepth)) then
            maxScrapingDepth = 1
        end

        local depth = 0

        for page in Paginator.New(http, dom, '//a[contains(@class,"nextpostslink")]//@href') do

            EnqueueAllGalleries(page)

            depth = depth + 1

            if(depth >= tonumber(maxScrapingDepth)) then
                break
            end

        end

    end

end

function GetPages()

    local imageUrls = dom.SelectValues('//div[contains(@class,"image-wrapper")]//img/@data-src')

    if(isempty(imagUrls)) then
        imageUrls = dom.SelectValues('//div[contains(@class,"lazy-listing")]//img/@src')
    end

    for imageUrl in imageUrls do

        -- Strip any resolution modifiers in the URL so we can get the full-size image.

        imageUrl = imageUrl:before('&w=')
            :before('&amp;w=')

        imageUrl = RegexReplace(imageUrl, '(\\-\\d+px)(\\..+?)$', '$2')
        imageUrl = RegexReplace(imageUrl, '\\/\\/hencover\\.xyz\\/preview\\/', '//henread.xyz/')

        pages.Add(imageUrl)

    end

end
