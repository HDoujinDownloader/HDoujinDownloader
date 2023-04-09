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

    -- Switch to "10 pages" mode, which allows us to access all of the pages.
    -- We will be redirected multiple times.

    url = url:trim('/') .. '-10-1.html'
    dom = Dom.New(http.Get(url))

    GetPagesFromArray()

    -- Some of the subdomains use a different reader where the images are directly in the HTML.
    -- We can only get 10 images at a time.

    if(isempty(pages)) then

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

    -- This doesn't seem to work anymore, but I've left it here just in case (relied on by other modules with the same reader).

    local imagesJsonStr = dom.SelectValue('//script[contains(.,"all_imgs_url")]')
        :regex('all_imgs_url:\\s*(\\[[^\\]]+\\])', 1)

    if(not isempty(imagesJsonStr)) then
        pages.AddRange(Json.New(imagesJsonStr))
    end

end
