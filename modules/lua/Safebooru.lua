require "Gelbooru"

local BaseGetInfo = GetInfo
local BaseBeforeDownloadPage = BeforeDownloadPage

function Register()

    module.Name = 'Safebooru'
    module.Type = 'Artist CG'
    module.Strict = false

    module.Domains.Add('*.booru.org')
    module.Domains.Add('hypnohub.net', 'HypnoHub')
    module.Domains.Add('realbooru.com', 'Realbooru')
    module.Domains.Add('rule34.xxx', 'Rule34')
    module.Domains.Add('safebooru.org')
    module.Domains.Add('xbooru.com', 'Xbooru')

end

local function GetPostUrlsFromResultPage()
    return dom.SelectValues('//*[contains(@class,"thumb") and a[@id]]/a/@href')
end

local function GetNextResultsUrl()
    return dom.SelectValue('//div[contains(@class,"pagination") or contains(@id,"paginator")]//a[contains(@alt,"next")]/@href')
end

function GetInfo()

    BaseGetInfo()

    info.Title = dom.SelectValue('//title')
    info.Source = dom.SelectValue('//div[contains(@id,"header")]//h2')

    if(info.Title:contains('/')) then
        info.Title = info.Title:after('/')
    else
        info.Title = dom.SelectValue('//input[contains(@name,"tags")]/@value')
    end

    if(isempty(info.PageCount) or tostring(info.PageCount) == '0') then
        info.PageCount = GetPostUrlsFromResultPage().Count()
    end

end

function GetPages()

    local nextResultsUrl = GetNextResultsUrl()

    pages.AddRange(GetPostUrlsFromResultPage())

    if(not isempty(nextResultsUrl)) then
        pages.Add(nextResultsUrl)
    end

end

function BeforeDownloadPage()

    BaseBeforeDownloadPage()

    if(isempty(page.Url)) then

        -- If we failed to get an original image URL, use the preview image URL instead.
        -- Note that some boorus only have a preview image available.

        page.Url = dom.SelectValue('//img[@id="image"]/@src')

        if(isempty(page.Url)) then
            page.Url = dom.SelectValue('//div[contains(@class,"imageContainer")]//video/source/@src')
        end

    end

end
