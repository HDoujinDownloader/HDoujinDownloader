function Register()

    module.Name = 'MangaOwl'
    module.Language = 'English'

    module.Domains.Add('mangaowl.net')
    
    -- These domains are used for the reader.

    module.Domains.Add('mangaowl.com')
    module.Domains.Add('mostraveller.com')
    module.Domains.Add('thefashion101.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h2')
    info.AlternativeTitle = dom.SelectValue('//span[contains(text(),"Synonyms")]/following-sibling::text()')
    info.DateReleased = dom.SelectValue('//span[contains(text(),"Released")]/following-sibling::text()')
    info.Tags = dom.SelectValues('//p[contains(.,"Genres")]/following-sibling::p[1]/a')
    info.Author = dom.SelectValue('//span[contains(text(),"Author")]/following-sibling::*')
    info.Status = dom.SelectValue('//span[contains(text(),"Pub. status")]/following-sibling::text()')
    info.Summary = dom.SelectValue('//span[contains(text(),"Story Line")]/following-sibling::text()')
    info.Characters = dom.SelectValues('//h4[contains(text(),"Characters")]/following-sibling::div//nobr')

end

function GetChapters()

    for node in dom.SelectElements('//a[contains(@class,"chapter-url")]') do

        local title = node.SelectValue('label[1]')
        local url = node.SelectValue('@href')

        chapters.Add(url, title)

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[@id="owl_container"]//img/@data-src'))

end
