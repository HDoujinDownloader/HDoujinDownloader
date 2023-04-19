function Register()

    module.Name = 'NineManga'
    module.Language = 'Spanish'
    module.Adult = false

    module.Domains.Add('br.ninemanga.com')
    module.Domains.Add('de.ninemanga.com')
    module.Domains.Add('es.ninemanga.com')
    module.Domains.Add('fr.ninemanga.com')
    module.Domains.Add('it.ninemanga.com')
    module.Domains.Add('my.ninemanga.com')
    module.Domains.Add('ninemanga.com')
    module.Domains.Add('ru.ninemanga.com')

end

function GetInfo()

    info.Title = CleanTitle(dom.SelectValue('//h1'))
    info.Tags = dom.SelectValues('//li[contains(@itemprop,"genre")]/a')
    info.Status = dom.SelectValue('//li/a[contains(@class,"red")]')
    info.Summary = dom.SelectValue('//p/b/following-sibling::text()')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//a[contains(@class,"chapter_list")]'))

    chapters.Reverse()

end

function GetPages()

    -- Use GetResponse so we can get the URL of the page we get redirected to.
    -- This allows us to generate the full URL for the JavaScript redirect.

    local httpResponse = http.GetResponse(url)

    url = httpResponse.Url
    dom = Dom.New(httpResponse.Body)

    -- Follow the JavaScript redirect if we need to.

    local redirectScript = dom.SelectValue('//script[contains(text(), "window.location.href")]')
    local redirectUrl = redirectScript:regex('window\\.location\\.href\\s*=\\s*"([^"]+)', 1)

    if(not isempty(redirectUrl)) then

        http.Referer = url

        url = GetRooted(redirectUrl, url)
        dom = Dom.New(http.Get(url))

    end

    GetPagesFromArray()

    if(isempty(pages)) then

        -- Switch to "10 pages" mode, which allows us to access all of the pages.
        -- We will be redirected multiple times.
        
        -- This is no longer relevant for NineManga itself, but it is for some dependent modules (e.g. NiAdd).

        url = RegexReplace(url, '(?:\\/|\\.html)$', '-10-1.html')
        dom = Dom.New(http.Get(url))

        GetPagesFromArray()

    end

    if(isempty(pages)) then

        -- Some of the subdomains use a different reader where the images are directly in the HTML.
        -- We can only get 10 images at a time.

        -- It will paginate into the next chapter, so make sure we only get the pages for this chapter.

        local chapterSlug = url:regex('\\/chapter(\\/[^\\/]+\\/)', 1)

        for page in Paginator.New(http, dom, '//div[contains(@class,"btn-next")]/a[contains(@href, "' .. chapterSlug .. '")]/@href') do
    
            local imageUrls = page.SelectValues('//img[contains(@class,"manga_pic")]/@src')

            if(isempty(imageUrls)) then
                break
            end

            pages.AddRange(imageUrls)
        
        end

    end

end

function CleanTitle(title)

    return RegexReplace(tostring(title), '(?:Manga)$', '')

end

function GetPagesFromArray()

    local imagesJsonStr = dom.SelectValue('//script[contains(.,"all_imgs_url")]')
        :regex('all_imgs_url:\\s*(\\[[^\\]]+\\])', 1)

    if(not isempty(imagesJsonStr)) then
        pages.AddRange(Json.New(imagesJsonStr))
    end

end
