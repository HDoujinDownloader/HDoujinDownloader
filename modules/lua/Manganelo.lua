function Register()

    module.Name = 'Manganelo'
    module.Language = 'English'

    module.Domains.Add('mangabat.com', 'Mangabat.com')
    module.Domains.Add('mangawk.com', 'MangaWK')
    module.Domains.Add('mangakakalot.com', 'Mangakakalot')
    module.Domains.Add('manganelo.com', 'Manganelo')
    
end

function GetInfo()

    FollowRedirect()

    info.Title = tostring(dom.GetElementsByTagName('h1')[0]):title()
    info.AlternativeTitle = dom.SelectValue('//td[contains(text(), "Alternative")]/following-sibling::td/text()')
    info.Author = dom.SelectValues('//td[contains(text(), "Author")]/following-sibling::td/a/text()')
    info.Status = dom.SelectValue('//td[contains(text(), "Status")]/following-sibling::td/text()')
    info.Tags = dom.SelectValues('//td[contains(text(), "Genres")]/following-sibling::td/a/text()')
    info.Summary = dom.SelectValue('//div[contains(@class, "info-description") or contains(@id, "noidungm")]'):after('Description :')

    -- The following cases apply specifically to Mangakakalot (mangakakalot.com).

    if(isempty(info.AlternativeTitle)) then
        info.AlternativeTitle = dom.SelectValue('//h2[contains(@class, "alternative")]')
    end

    if(isempty(info.Author)) then
        info.Author = dom.SelectValues('//li[contains(text(), "Author")]//a')
    end

    if(isempty(info.Status)) then
        info.Status = dom.SelectValue('//li[contains(text(), "Status")]'):after(':')
    end

    if(isempty(info.Tags)) then
        info.Tags = dom.SelectValues('//li[contains(text(), "Genres")]//a')
    end

end

function GetChapters()

    FollowRedirect()

    chapters.AddRange(dom.SelectElements('//div[contains(@class, "chapter-list")]//a'))

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class, "chapter-reader") or contains(@class, "vung-doc") or contains(@class, "vung_doc")]/img/@src'))

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
