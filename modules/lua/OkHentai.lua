function Register()

    module.Name = 'OkHentai'
    module.Adult = true
    module.Language = 'en'

    module.Domains.Add('okhentai.net')

end

local function CleanTitle(title)

    return RegexReplace(tostring(title):trim(), '(?:manga|doujinshi)\\s+\\d+\\s+pages$', '')

end

local function GetPageCount()

    return dom.SelectValue('//span[contains(@class,"pages")]'):after(':')

end

function GetInfo()

    info.Title = CleanTitle(dom.SelectValue('//h1'))
    info.OriginalTitle = dom.SelectValue('//h2')
    info.Tags = dom.SelectValues('//ul[contains(@class,"tags")]//a/text()[1]')
    info.Artist = dom.SelectValues('//ul[contains(@class,"artists")]//a/text()[1]')
    info.Language = dom.SelectValues('//ul[contains(@class,"languages")]//a/text()[1]')
    info.Type = dom.SelectValues('//ul[contains(@class,"categories")]//a/text()[1]')
    info.PageCount = GetPageCount()

end

function GetPages()

    local offset = 0
    local pageCount = tonumber(GetPageCount())

    repeat

        http.Headers['accept'] = '*/*'
        http.Headers['x-requested-with'] = 'XMLHttpRequest'

        url = SetParameter(url, 'offset', offset)
        dom = Dom.New(http.Get(url))

        local thumbnailUrls = dom.SelectValues('//div[contains(@class,"g_thumb")]//img/@src')

        if(isempty(thumbnailUrls)) then
            break
        end

        pages.AddRange(thumbnailUrls)

        offset = offset + thumbnailUrls.Count()
    
    until(pages.Count() >= pageCount)

    -- Convert thumbnail URLs to full image URLs.

    for page in pages do
        page.Url = RegexReplace(page.Url, '-r_\\d+x\\d+', '')
    end

end
