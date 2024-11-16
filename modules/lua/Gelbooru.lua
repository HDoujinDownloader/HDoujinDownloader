function Register()

    module.Name = 'Gelbooru'
    module.Type = 'Artist CG'
    module.Strict = false

    module.Domains.Add('gelbooru.com')

    -- Enable access to all content. 

   global.SetCookie(module.Domains.First(), "fringeBenefits", "yup")

end

local function GetPostUrlsFromResultPage()
    return dom.SelectValues('//article[contains(@class,"thumbnail-preview")]/a/@href')
end

local function GetNextResultsUrl()

    -- Note that the "next page" button isn't visible on the last several pages.

    local result = dom.SelectValue('//div[contains(@id,"paginator")]/a[contains(@alt,"next")]/@href')

    if(isempty(result)) then
        result = dom.SelectValue('//div[contains(@id,"paginator")]/b/following-sibling::a/@href')
    end

    return result

end

function GetInfo()

    info.Title = dom.SelectValue('//title'):before('|')
    info.Artist = dom.SelectValues('//li[contains(@class,"tag-type-artist")]//a[last()]')
    info.Characters = dom.SelectValues('//li[contains(@class,"tag-type-character")]//a[last()]')
    info.Parody = dom.SelectValues('//li[contains(@class,"tag-type-copyright")]//a[last()]')
    info.Tags = dom.SelectValues('//li[contains(@class,"tag-type-general")]//a[last()]')
    info.PageCount = GetParameter(dom.SelectValue('//div[contains(@id,"paginator")]//a[last()]/@href'), 'pid')

    if(isempty(info.PageCount)) then
        info.PageCount = GetPostUrlsFromResultPage().Count()
    end

end

function GetPages()

    -- Add all post URLs, and the next results URL.

    local nextResultsUrl = GetNextResultsUrl()

    pages.AddRange(GetPostUrlsFromResultPage())

    if(not isempty(nextResultsUrl)) then
        pages.Add(nextResultsUrl)
    end

end

function BeforeDownloadPage()

    local pageType = GetParameter(url, "s")

    if(pageType == 'view') then

        page.Url = dom.SelectValue('//a[contains(text(),"Original image")]/@href')

    elseif(pageType == 'list') then

        GetPages()

    end

end
