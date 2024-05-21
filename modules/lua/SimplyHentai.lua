function Register()

    module.Name = 'Simply Hentai'
    module.Adult = true

    module.Domains.Add('old.simply-hentai.com')
    module.Domains.Add('simply-hentai.com')
    module.Domains.Add('www.simply-hentai.com')

end

local function CleanTitle(title)

    return RegexReplace(tostring(title):trim(), '^All\\s*\\d+\\s+pages\\s+from\\s+', '')

end

function GetInfo()

    info.Title = CleanTitle(dom.SelectValue('//h1'))
    info.Series = dom.SelectValues('//div[contains(.,"Series")]/following-sibling::a[contains(@href,"/series/")]')
    info.Language = dom.SelectValues('//div[contains(.,"Language")]/following-sibling::a[contains(@href,"/language/")]')
    info.Tags = dom.SelectValues('//div[contains(.,"Tags")]/following-sibling::a[contains(@href,"/tag/")]')
    info.Artist = dom.SelectValues('//div[contains(.,"Artists")]/following-sibling::a[contains(@href,"/artist/")]')

end

function GetPages()

    -- Go to the "all pages" page.

    local allPagesUrl = dom.SelectValue('//a[contains(@href,"/all-pages")]/@href')

    if(not isempty(allPagesUrl)) then

        url = allPagesUrl
        dom = Dom.New(http.Get(allPagesUrl))

    end

    pages.AddRange(dom.SelectValues('//div[contains(@class,"image-wrapper")]/img/@data-src'))
    pages.AddRange(dom.SelectValues('//a[contains(@class,"image-preview")]//img/@data-src'))

    for page in pages do

        -- Convert the thumbnail URL to a full image URL.

        page.Url = page.Url
            :replace('/small_', '/')
            :replace('/thumb_', '/')

    end

end
