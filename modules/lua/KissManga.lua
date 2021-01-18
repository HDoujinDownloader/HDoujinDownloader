function Register()

    module.Name = 'KissManga'
    module.Language = 'English'
    
    module.Domains.Add('kissmanga.com', 'KissManga')
    module.Domains.Add('kissmanga.org', 'KissManga')

end

function GetInfo()

    info.Title = dom.SelectValue('//*[contains(@class,"bigChar")]')
    info.AlternativeTitle = dom.SelectValues('//span[contains(text(),"Other name")]/following-sibling::a')
    info.Tags = dom.SelectValues('//span[contains(text(),"Genres")]/following-sibling::a')
    info.Author = dom.SelectValues('//span[contains(text(),"Author")]/following-sibling::a')
    info.Status = dom.SelectValue('//span[contains(text(),"Status")]/following-sibling::text()')
    info.Summary = dom.SelectValue('//div[contains(@class,"summary")]/p')

    if(isempty(info.Title)) then
        info.Title = CleanTitle(dom.Title)
    end

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//div[contains(@class,"listing")]//a'))

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@id,"centerDivVideo")]/img/@src'))

end

function CleanTitle(title)

    return tostring(title)
        :after('Read manga')
        :beforelast(' online')
        :beforelast(' | ')
        :trim()
        :trim('manga')
        :trim()

end
