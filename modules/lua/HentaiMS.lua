function Register()

    module.Name = 'Load.LA'
    module.Adult = true

    module.Domains.Add('box.load.la')
    module.Domains.Add('hentai.ms')
    module.Domains.Add('load.la')

end

local function ShowAllThumbnails()

    local load = GetParameter(url, 'load')

    if(isempty(load)) then

        url = dom.SelectValue('//a[contains(text(),"View all")]/@href')

        if(not isempty(url)) then
            dom = Dom.New(http.Get(url))
        end

    end

end

function GetInfo()

    info.Title = dom.SelectValue('//h2/a[last()]')
    info.Tags = dom.SelectValues('//div[a[contains(.,"Tags")]]/a[contains(@href,"related=tags")]')
    info.PageCount = dom.SelectValue('//a[contains(text()," Images")]'):regex('\\s*(\\d+)', 1)

end

function GetPages()

    ShowAllThumbnails()

    -- The gallery doesn't have many images, so just get the thumbnail URLs immediately.

    pages.AddRange(dom.SelectValues('//table[contains(@class,"search_gallery")]//td[contains(@class,"search_gallery_item")]/a/@href'))
 
    -- The gallery has a separate thumbnail page, so get all of the thumbnail URLs from there.

    if(isempty(pages)) then
        pages.AddRange(dom.SelectValues('//td[contains(@class,"search_gallery_item")]/a/@href'))
    end

end

function BeforeDownloadPage()

    dom = Dom.New(http.Get(page.Url))

    local originalSizeUrl = dom.SelectValue('//a[contains(text(),"Original Size")]/@href')

    if(not isempty(originalSizeUrl)) then
        dom = Dom.New(http.Get(originalSizeUrl))
    end

    page.Url = dom.SelectValue('//center//img/@src')

end
