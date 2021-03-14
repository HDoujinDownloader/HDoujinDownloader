require "ImageVenue"

local BeforeDownloadPageImageVenue = BeforeDownloadPage

require "TurboImageHost"

local BeforeDownloadPageTurboImageHost = BeforeDownloadPage

function Register()

    module.Name = 'HentaiRules'
    module.Adult = true
    
    module.Domains.Add('hentairules.net')

end

function GetInfo()

    if(not url:contains('/gal')) then

        -- Added from blog post.
        -- e.g. /2021/03/13/english-kosuke-haruhito-asics-hentai/

        -- Add all galleries in the blog post to the download queue.

        for galleryUrl in dom.SelectValues('//article[contains(@id,"post-")]//a[contains(@href,"/gal")]/@href') do
            Enqueue(galleryUrl)
        end

        info.Ignore = true

    elseif(url:contains('/galleries')) then
    
        -- Added from locally-hosted gallery.
        -- e.g. /galleries10/index.php?/category/195
        -- e.g. /galleries13/index.php?/category/298

        info.Title = dom.SelectValue('//h2/a[last()]')
        info.PageCount = dom.SelectValue('//h2/text()[last()]'):regex('\\[(\\d+)\\]', 1)

    elseif(url:contains('/gal/')) then

        -- Added from externally-hosted gallery (ImageVenue, TurboImageHost, etc.).
        
        info.Title = url:regex('\\/([^\\/]+?)\\.html$', 1):replace('_', ' '):title()
        info.PageCount = dom.SelectValues('//a[img]/@href').Count()

        if(isempty(info.Title)) then
            info.Title = dom.Title
        end

    end

    if(not isempty(info.Title)) then

        GetMetadataFromTitle(info, info.Title)

        info.Title = CleanTitle(info.Title)

    end

end

function GetPages()

    if(url:contains('/galleries')) then

        for page in Paginator.New(http, dom, '//a[@rel="next"]/@href') do
    
            local thumbnailUrls = page.SelectValues('//img[contains(@class,"thumbnail")]/@src')
    
            for i = 0, thumbnailUrls.Count() - 1 do
    
                local thumbnailUrl = thumbnailUrls[i]

                thumbnailUrl = thumbnailUrl:replace('-th.', '.')
                    :replace('_data/i/', '')
    
                pages.Add(thumbnailUrl)
    
            end
    
        end

    elseif(url:contains('/gal/')) then

        pages.AddRange(dom.SelectValues('//a[img]/@href'))

    end

end

function BeforeDownloadPage()

    if(GetDomain(page.Url) == 'imagevenue.com') then
        BeforeDownloadPageImageVenue()
    elseif(GetDomain(page.Url) == 'turboimagehost.com') then
        BeforeDownloadPageTurboImageHost()
    end

end

function CleanTitle(title)

    return tostring(title):before('[')

end

function GetMetadataFromTitle(info, title)

    title = tostring(title)

    info.Language = title:regex('\\[([^\\]]+)\\]', 1)
    info.Type = title:regex('doujinshi')
    info.Parody = title:regex('parodying(?: the )?(.+?)(?:$|,| game)', 1)
    info.Artist = title:regex('by (.+?)(?:$|,|\\()', 1)
    info.Circle = title:regex('\\(circle (.+?)\\)', 1)

end
