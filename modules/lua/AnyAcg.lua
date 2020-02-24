function Register()

    module.Name = 'AnyACG'

    module.Domains.Add('bato.to', 'BATO.TO')
    module.Domains.Add('mangaseinen.com', 'mangaseinen.com')
    module.Domains.Add('mangatensei.com', 'MangaTensei.com')
    module.Domains.Add('rawmanga.info', 'raw manga')

end

function GetInfo()

    info.Title = dom.GetElementsByTagName('h3')[0]
    info.Language = dom.SelectValue('//span[contains(@class, "flag")]/@class'):regex('flag_(\\w+)', 1)
    info.Author = dom.SelectElements('//b[contains(text(), "Author")]/following-sibling::span/a')
    info.Tags = List.New(tostring(dom.SelectElement('//b[contains(text(), "Genre")]/following-sibling::span')):split('/'))
    info.Status = dom.SelectValue('//b[contains(text(), "Status")]/following-sibling::span/text()')
    info.Summary = dom.SelectValue('//pre/text()')
end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//div[contains(@class, "chapter-list")]//a[@class="chapt"]'))

    chapters.Reverse()

end

function GetPages()

    local doc = http.Get(url)
    local imagesJson = Json.New(doc:between('var images = ', ';'))
    
    pages.AddRange(imagesJson.SelectValues('*'))

end
