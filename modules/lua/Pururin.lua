function Register()

    module.Name = 'Pururin'
    module.Language = 'English'
    module.Adult = true

    module.Domains.Add('pururin.io')
    module.Domains.Add('pururin.me')
    module.Domains.Add('pururin.to')
    module.Domains.Add('pururin.us')

end

function GetInfo()

    RedirectToSummaryPage()

    info.Title = dom.SelectValue('//h1'):before('/')
    info.OriginalTitle = dom.SelectValue('//h1'):after('/')
    info.AlternativeTitle = dom.SelectValue('//div[contains(@class,"alt-title")]')
    info.Artist = dom.SelectValues('//td[contains(text(),"Artist")]/following-sibling::td//a')
    info.Circle = dom.SelectValues('//td[contains(text(),"Circle")]/following-sibling::td//a')
    info.Parody = dom.SelectValues('//td[contains(text(),"Parody")]/following-sibling::td//a')
    info.Tags = dom.SelectValues('//td[contains(text(),"Contents")]/following-sibling::td//a')
    info.Type = dom.SelectValues('//td[contains(text(),"Category")]/following-sibling::td//a')
    info.Characters = dom.SelectValues('//td[contains(text(),"Character")]/following-sibling::td//a')
    info.Language = dom.SelectValues('//td[contains(text(),"Language")]/following-sibling::td//a')
    info.Scanlator = dom.SelectValues('//td[contains(text(),"Scanlator")]/following-sibling::td//a')

end

function GetChapters()

    RedirectToSummaryPage()

    chapters.AddRange(dom.SelectElements('//table[contains(@class,"table-collection")]//a'))

end

function GetPages()

    RedirectToSummaryPage()

    for thumbnailNode in dom.SelectElements('//div[contains(@class,"gallery-preview")]//img') do
        
        local imageUrl = thumbnailNode.SelectValue('./@src')

        if(isempty(imageUrl)) then
            imageUrl = thumbnailNode.SelectValue('./@data-src') 
        end
        
        imageUrl = RegexReplace(imageUrl, '\\/(\\d+)t\\.', '/$1.')

        pages.Add(imageUrl)
        
    end

end

function GetGalleryId()

    return url:regex('\\/(?:gallery|read)\\/(\\d+)', 1)

end

function RedirectToSummaryPage()

    -- If a reader URL was added, go back to the summary page.

    if(url:contains('/read/')) then
        
        local galleryId = GetGalleryId()

        url = GetRooted('/gallery/' .. galleryId .. '/', url)
        dom = Dom.New(http.Get(url))

    end

end
