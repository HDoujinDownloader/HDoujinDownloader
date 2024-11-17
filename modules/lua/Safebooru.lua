require "Gelbooru"

local BaseGetInfo = GetInfo

function Register()

    module.Name = 'Safebooru'
    module.Type = 'Artist CG'
    module.Strict = false

    module.Domains.Add('safebooru.org')

end

local function GetPostUrlsFromResultPage()
    return dom.SelectValues('//span[contains(@class,"thumb")]/a/@href')
end

local function GetNextResultsUrl()
    return dom.SelectValue('//div[contains(@class,"pagination")]//a[contains(@alt,"next")]/@href')
end

function GetInfo()

    BaseGetInfo()

    info.Title = dom.SelectValue('//title'):after('/')

    if(isempty(info.PageCount)) then
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
