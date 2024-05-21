function Register()

    module.Name = 'ArtUntamed'
    module.Adult = true

    module.Domains.Add('artuntamed.com')

end

local function GetImagesFromMediaPage()

    return dom.SelectValues('//div[contains(@class,"media-container")]//img/@src')

end

function GetInfo()

    info.Title = dom.SelectValue('//title'):beforelast('|')
    info.Artist = info.Title:regex('Media added by\\s([^|]+)', 1)
    info.PageCount = GetImagesFromMediaPage().Count()

    if(tonumber(info.PageCount) <= 0) then
        info.PageCount = '?'
    end

end

function GetPages()

    -- URLs on this site can take many forms:
    -- /index.php?tags/<tag>/
    -- /index.php?media/users/<user-id>/
    -- /index.php?media/<media-id>/
    -- /index.php?media/

    for page in Paginator.New(http, dom, '//div[contains(@class,"pageNav")]//a[contains(@class,"next")]/@href') do
    
        -- Add all media URLs if this is a thumbnail gallery.

        pages.AddRange(page.SelectValues('//a[contains(@class,"js-lbImage")]/@href'))
    
        -- Add all media URLs if this is a tag gallery.

        pages.AddRange(page.SelectValues('//*[contains(@class,"contentRow-title")]//a/@href'))

    end


    if(isempty(pages)) then
        pages.Add(url)
    end

    -- Galleries are organized reverse-chronologically.

    pages.Reverse()

end

function BeforeDownloadPage()

    if(page.Url:endswith('/full')) then
        return
    end

    page.Url = GetImagesFromMediaPage()[0]

end
