-- The "swat manga" theme is an Arabic manga website theme by themearabia (Hossam Hamed).
-- Websites using this theme will have a comment at the top and bottom of the HTML with author credits.

require 'ManhwaFreak'

function Register()

    module.Name = 'swat manga'
    module.Language = 'Arabic'

    module.Domains.Add('healteer.com', 'سوات مانجا')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Status = dom.SelectValue('//b[contains(text(),"الحالة")]/following-sibling::a')
    info.Type = dom.SelectValue('//b[contains(text(),"النوع")]/following-sibling::a')
    info.Author = dom.SelectValue('//b[contains(text(),"المؤلف")]/following-sibling::text()')
    info.Publisher = dom.SelectValue('//b[contains(text(),"الناشر")]/following-sibling::text()')
    info.DateReleased = dom.SelectValue('//b[contains(text(),"تاريخ النشر")]/following-sibling::*')
    info.Summary = dom.SelectValue('//span[contains(@class,"desc")]')
    info.Tags = dom.SelectValues('//b[contains(text(),"التصنيف")]/following-sibling::a')

    if(API_VERSION > 20240919) then
        info.Genres = dom.SelectValues('//b[contains(text(),"التصنيف")]/following-sibling::a')
    end

end

function GetChapters()
 
    chapters.AddRange(dom.SelectElements('//div[contains(@class,"releases")]/following-sibling::ul//span[contains(@class,"lchx")]/a'))

    chapters.Reverse()

end
