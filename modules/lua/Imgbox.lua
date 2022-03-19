function Register()

    module.Name = 'imgbox'

    module.Domains.Add('imgbox.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//div[@id="gallery-view"]/h1'):beforelast('-')

    if(isempty(info.Title)) then
        info.Title = dom.SelectValue('//img[contains(@class,"image-content")]/@title')
    end

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[@id="gallery-view-content"]/a/@href'))

    if(isempty(pages)) then
        pages.Add(url)
    end

end

function BeforeDownloadPage()

    if(page.Url:contains('.imgbox.com')) then
        return
    end

    dom = Dom.New(http.Get(page.Url))

    page.Url = dom.SelectValue('//img[contains(@class,"image-content")]/@src')

end
