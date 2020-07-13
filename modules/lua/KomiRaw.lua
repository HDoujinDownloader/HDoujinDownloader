function Register() 

    module.Name = 'KomiRaw'
    module.Language = 'Japanese'
    module.Type = 'Manga'

    module.Domains.Add('komiraw.com', 'Komiraw.com')
    module.Domains.Add('manga11.com', 'Manga11')

end

function GetInfo()

    info.Title = dom.SelectValue('//h3[contains(@class,"title")]')
    info.OriginalTitle = info.Title:before('|'):trim()
    info.Summary = dom.SelectValue('//p')
    info.Author = dom.SelectValues('//h3[contains(text(),"Author")]/following-sibling::a')
    info.Tags = dom.SelectValues('//h3[contains(text(),"Genre")]/following-sibling::a')
    
    if(isempty(info.Title)) then

        -- Added from chapter page URL.

        info.Title = dom.SelectValue('//a[@class="chapter-title"]')

    end

end

function GetChapters()

    for page in Paginator.New(http, dom, '//a[@rel="next"]/@href') do

        chapters.AddRange(page.SelectElements('//ul[contains(@class,"list-chapter")]//a'))

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//img[contains(@class,"chapter-img ")]/@src'))

end
