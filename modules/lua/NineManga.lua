function Register()

    module.Name = 'NineManga'
    module.Language = 'Spanish'
    module.Adult = false

    module.Domains.Add('br.ninemanga.com')
    module.Domains.Add('de.ninemanga.com')
    module.Domains.Add('es.ninemanga.com')
    module.Domains.Add('fr.ninemanga.com')
    module.Domains.Add('it.ninemanga.com')
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

    local imagesJsonStr = dom.SelectValue('//script[contains(.,"all_imgs_url")]')
        :regex('all_imgs_url:\\s*(\\[[^\\]]+\\])', 1)

    if(not isempty(imagesJsonStr)) then
        pages.AddRange(Json.New(imagesJsonStr))
    end

end

function CleanTitle(title)

    return RegexReplace(tostring(title), '(?:Manga)$', '')

end
