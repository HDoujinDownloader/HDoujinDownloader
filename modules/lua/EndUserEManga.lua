function Register()

    -- "eManga" is a theme by EndUser (http://enduser.id).

    module.Name = 'eManga (EndUser)'
    module.Language = 'English'

    module.Domains.Add('manganelo.today', 'MangaNelo.Today')
    module.Domains.Add('manganelo.online', 'MangaNelo.online')

end

function GetInfo()
   
    info.Title = dom.GetElementsByTagName('h1')[0]

    if(GetDomain(url) == 'manganelo.today') then

        info.Summary = dom.SelectValue('//div[@id="noidungm"]/text()')
        info.AlternativeTitle = dom.SelectValue('//li[descendant::b[contains(text(),"Alternative")]]/text()[last()]')
        info.Author = dom.SelectValue('//li[descendant::b[contains(text(),"Author")]]/text()[last()]'):after(':')
        info.Status = dom.SelectValue('//li[descendant::b[contains(text(),"Status")]]/text()[last()]')
        info.Tags = dom.SelectValues('//li[descendant::b[contains(text(),"Genres")]]//a/text()')

    elseif(GetDomain(url) == 'manganelo.online') then

        info.Summary = dom.SelectValue('//div[contains(@class,"manga-content")]/text()')
        info.AlternativeTitle = dom.SelectValue('//p[descendant::span[contains(text(),"Alternative")]]/text()[last()]')
        info.Author = dom.SelectValue('//p[descendant::span[contains(text(),"Author")]]/text()[last()]')
        info.Type = dom.SelectValue('//p[descendant::span[contains(text(),"Type")]]/text()[last()]')
        info.Status = dom.SelectValue('//p[descendant::span[contains(text(),"Status")]]/text()[last()]')
        info.Tags = dom.SelectValues('//p[descendant::span[contains(text(),"Genre")]]/a/text()')

    end

end

function GetChapters()

    if(GetDomain(url) == 'manganelo.today') then

        chapters.AddRange(dom.SelectElements('//div[@class="offzone"]/following-sibling::ul/li//a'))

    elseif(GetDomain(url) == 'manganelo.online') then

        chapters.AddRange(dom.SelectElements('//div[@class="total-chapter"]/div[@class="chapter-list"]//a'))

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValue('//p[@id="arraydata"]/text()'))

    pages.Referer = '' -- Hosts like mangapark.net 403 with a referer

end
