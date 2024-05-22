-- This site uses a WordPress theme called "MovieScript" (https://themetix.com/moviescript).

function Register()

    module.Name = 'HentaiIdTv'
    
    module.Adult = true
    module.Strict = false -- some galleries have blank image URLs at the end

    module.Domains.Add('hentai-id.tv', 'HENTAI-ID.TV')

end

local function CleanTitle(title)

    return tostring(title)
        :beforelast(' | ')
        :before(' - MangaH')

end

local function GetPageCount(dom)

    return dom.SelectValue('//option[last()]/@value') + 1 -- page numbers start at 0

end

function GetInfo()

    info.Title = CleanTitle(dom.SelectValue('//title'))
    info.Language = info.Title:regex('\\[(.+?)\\]$', 1)

    -- There are interstitial pages that link to the reader.
    -- e.g. //hentai-id.tv/<title>/ -> //hentai-id.tv/manga.php?id=<id>

    -- They might also use a redirect service.
    -- e.g. //ouo.io/s/<id>?s=<readerUrl>

    local readerUrl = dom.SelectValue('//div[contains(@class, "mm2")]/a/@href'):after('?s=')

    if(not isempty(readerUrl)) then

        info.Url = readerUrl

        dom = dom.New(http.Get(readerUrl))

    end

    info.PageCount = GetPageCount(dom)

    -- Make sure that we're on the first reader page.

    info.Url = RegexReplace(info.Url, '&p=\\d+$', '&p=1')

end

function GetPages()

    local pageCount = tonumber(GetPageCount(dom))

    -- There's no way to get all of the images at once, so we have to go page-by-page.

    for i = 1, pageCount do

        -- Get the image.

        local imageUrl = dom.SelectValue('//div[contains(@class, "body-img")]//img/@src')

        if(not isempty(imageUrl)) then
            pages.Add(imageUrl)
        end

        -- Get the next page.

        local nextPageUrl = dom.SelectValue('//div[contains(@class, "body-img")]/a/@href')

        if(not isempty(nextPageUrl) and i < pageCount) then
            dom = Dom.New(http.Get(nextPageUrl))
        end

    end

end
