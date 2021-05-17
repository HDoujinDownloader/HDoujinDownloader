function Register()

    module.Name = 'Manganelo'
    module.Language = 'English'

    module.Domains.Add('mangabat.com', 'Mangabat.com')
    module.Domains.Add('mangawk.com', 'MangaWK')
    module.Domains.Add('mangakakalot.city', 'Mangakakalot')
    module.Domains.Add('mangakakalot.com', 'Mangakakalot')
    module.Domains.Add('mangakakalot.tv', 'Mangakakalot')
    module.Domains.Add('manganelo.com', 'Manganelo')
    module.Domains.Add('manganelo.tv', 'Manganelo')

    module.Settings.AddCheck('Try other image servers', true)
        .WithToolTip('If enabled, the image URLs from the alternative image server(s) will be used as backup.')
    
end

function GetInfo()

    FollowRedirect()

    info.Title = tostring(dom.GetElementsByTagName('h1')[0]):title()
    info.AlternativeTitle = dom.SelectValue('//td[contains(., "Alternative")]/following-sibling::td/text()')
    info.Author = dom.SelectValues('//td[contains(., "Author")]/following-sibling::td/a/text()')
    info.Status = dom.SelectValue('//td[contains(., "Status")]/following-sibling::td/text()')
    info.Tags = dom.SelectValues('//td[contains(., "Genres")]/following-sibling::td/a/text()')
    info.Summary = dom.SelectValue('//div[contains(@class, "info-description") or contains(@id, "noidungm")]'):after('Description :')

    -- The following cases apply specifically to Mangakakalot (mangakakalot.com).

    if(isempty(info.AlternativeTitle)) then -- mangakakalot.com
        info.AlternativeTitle = dom.SelectValue('//h2[contains(@class, "alternative")]')
    end

    if(isempty(info.Author)) then -- mangakakalot.com
        info.Author = dom.SelectValues('//li[contains(text(), "Author")]//a')
    end

    if(isempty(info.Author)) then -- mangakakalot.city
        info.Author = dom.SelectValue('//li[contains(text(), "Author")]'):after(':')
    end

    if(isempty(info.Status)) then -- mangakakalot.com
        info.Status = dom.SelectValue('//li[contains(text(), "Status")]'):after(':')
    end

    if(isempty(info.Tags)) then -- mangakakalot.com
        info.Tags = dom.SelectValues('//li[contains(text(), "Genre") or contains(text(), "Genres")]//a')
    end

end

function GetChapters()

    FollowRedirect()

    chapters.AddRange(dom.SelectElements('//div[contains(@class, "chapter-list")]//a'))

    chapters.Reverse()

end

function GetPages()

    -- Get all image URLs for the current image server.

    pages.AddRange(GetImageUrls())

    -- Add the image URLs from the other servers as backup URLs.
    -- Which server the images are loaded from is dependent upon the value of the "content_server" cookie.
    -- For example, the second image server is used if "content_server" is "server2".

    if(toboolean(module.Settings['Try other image servers'])) then

        local contentServerUrls = dom.SelectValues('//a[contains(@class,"server-image-btn")]/@data-l')

        if(not isempty(contentServerUrls)) then
    
            local contentServerUrl = contentServerUrls.First()
    
            -- This request sets the "content_server" cookie and updates the list of images.
    
            http.Get(contentServerUrl)

            dom = Dom.New(http.Get(url))
    
            local backupImageUrls = GetImageUrls()
            
            for i = 0, math.min(backupImageUrls.Count(), pages.Count()) - 1 do

                pages[i].BackupUrls.Add(backupImageUrls[i])

            end
            
        end

    end

end

function FollowRedirect()

    -- Mangakakalot (mangakakalot.com) has some URLs redirecting to new ones.
    -- https://doujindownloader.com/forum/viewtopic.php?f=9&t=1612

    -- Follow the redirect to make sure we're on the correct page.

    local redirectUrl = dom.SelectValue('//head/script/text()')
        :regex('window\\.location\\.assign\\("([^"]+)', 1)

    if(not isempty(redirectUrl)) then
        dom = Dom.New(http.Get(redirectUrl))
    end

end

function GetImageUrls()

    local imageList = List.New()

    imageList.AddRange(dom.SelectValues('//div[contains(@class, "chapter-reader") or contains(@class, "vung-doc") or contains(@class, "vung_doc")]/img/@src'))

    -- Update (09/03/2021): We need to use the data-src attribute for Manganelo (manganelo.tv).

    if(isempty(imageList)) then
        imageList.AddRange(dom.SelectValues('//div[contains(@class, "chapter-reader") or @id="vungdoc"]/img/@data-src'))
    end

    -- Update (23/03/2021): The images are stored in an array on mangakakalot.city.

    if(isempty(imageList)) then

        local pageArray = dom.SelectValue('//p[@id="arraydata"]')

        imageList.AddRange(pageArray:split(','))

    end

    return imageList

end
