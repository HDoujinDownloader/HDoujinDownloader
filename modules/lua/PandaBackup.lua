function Register()

    module.Name = "Panda Backup"
    module.Adult = true

    module.Strict = false
    module.DeferHttpRequests = true

    module.Domains.Add("panda.chaika.moe")

end

local function CleanTags(value)

    return tostring(value)
        :replace("_", " ")
        :title()

end

local function GetArchiveUrl()

    if(url:contains('/download/')) then
    
        url = RegexReplace(url, '\\/download\\/?', '')
    
    elseif(url:contains('/gallery/')) then
        
        dom = Dom.New(http.Get(url))
        url = dom.SelectValue('//li[contains(.,"Related archives:")]//a[1]/@href')

    end

    return url

end

function GetInfo()

    -- There are gallery, archive, and download URLs.
    -- We want to normalize the URL so that we have a simple archive URL.

    url = GetArchiveUrl()
    dom = Dom.New(http.Get(url))

    info.Url = url
    info.Title = dom.SelectValue('//h5')
    info.OriginalTitle = dom.SelectValue('//ul[contains(@class,"info")]//li[contains(@class,"subtitle")][1]')
    info.PageCount = dom.SelectValue('//th[contains(text(),"Images")]/following-sibling::td')
    info.Type = dom.SelectValues('//th[contains(text(),"Category")]/following-sibling::td//a')
    info.Artist = CleanTags(dom.SelectValues('//label[contains(text(),"artist:")]/following-sibling::a'))
    info.Circle = CleanTags(dom.SelectValues('//label[contains(text(),"group:")]/following-sibling::a'))
    info.Parody = CleanTags(dom.SelectValues('//label[contains(text(),"parody:")]/following-sibling::a'))
    info.Tags = CleanTags(dom.SelectValues('//label[contains(text(),"male:") or contains(text(),"mixed:")]/following-sibling::a'))

end

function GetPages()

    url = GetArchiveUrl()
    dom = Dom.New(http.Get(url))

    local downloadUrl = dom.SelectValue('//a[contains(@href,"/download/")]/@href')
    local page = PageInfo.New(downloadUrl)

    page.ExtractContents = true
    page.FileExtensionHint = ".zip"

    pages.Add(page)

end
