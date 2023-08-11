function Register()

    module.Name = 'ImageFap'
    module.Adult = true

    module.Domains.Add('imagefap.com')
    module.Domains.Add('www.imagefap.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//title')
    --info.Uploader = dom.SelectValue('//font[contains(text(),"Uploaded by")]'):after('Uploaded by')
    info.Summary = dom.SelectValue('//span[contains(@id,"cnt_description")]')
    info.Tags = dom.SelectValues('//div[contains(@id,"cnt_tags")]//a')
    info.PageCount = dom.SelectValue('//img[contains(@alt,"Free porn pics")]/@alt'):regex('(\\d+)\\s*pics', 1)
    
    if(isempty(info.Title)) then
        Fail(Error.CaptchaRequired)
    end

end

function GetPages()

    -- Use "one page" view to access a greater number of images at once.
    -- We'll still need to paginate for larger galleries.

    url = dom.SelectValue('//a[contains(.,"One page")]/@href')

    if(isempty(url)) then
        url = SetParameter(url, 'view', '2')
    end
    
    dom = Dom.New(http.Get(url))

    for page in Paginator.New(http, dom, '//div[contains(@id,"gallery")]//a[contains(text(),"next")]/@href') do

        pages.AddRange(page.SelectValues('//div[contains(@id,"gallery")]//table//td/a/@href'))

    end

end

function BeforeDownloadPage()

    local dom = Dom.New(http.Get(page.Url))
    local photoId = url:regex('\\/photo\\/(\\d+)', 1)

    page.Url = dom.SelectValue('//ul[contains(@class,"thumbs")]//a[@imageid="' .. photoId .. '"]/@original')

end
