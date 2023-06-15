function Register()

    module.Name = 'Death Toll Reader'
    module.Language = 'English'
    module.Adult = false

    module.Domains.Add('reader.deathtollscans.net')

end

function GetInfo()

    BypassMatureContentWarning()

    info.Title = dom.SelectValue('//h1[contains(@class,"title")]')
    info.Summary = CleanMetadataFieldValue(dom.SelectValue('//b[contains(text(),"Synopsis")]/following-sibling::text()[1]'))
    info.Author = CleanMetadataFieldValue(dom.SelectValue('//b[contains(text(),"Author")]/following-sibling::text()[1]'))
    info.Artist = CleanMetadataFieldValue(dom.SelectValue('//b[contains(text(),"Artist")]/following-sibling::text()[1]'))
    info.Scanlator = module.Name
    
end

function GetChapters()

    BypassMatureContentWarning()

    -- Sometimes chapters are grouped into volumes.

    local volumeNodes = dom.SelectElements('//div[contains(@class,"title") and contains(text(), "Volume")]')

    if(volumeNodes.Count() > 0) then

        -- Some are not grouped into volumes

        chapters.AddRange(dom.SelectElements('//div[contains(@class,"title") and contains(text(), "Chapter")]/following-sibling::div/div[contains(@class,"title")]/a'))

        -- We need to get them per-volume or else the ordering will be messed up.
        -- For example, Volume 1 might have Chapters 10 -> 1, and Volume 2 20 -> 11. We need to reverse each group separately (volumes and chapters).

        volumeNodes.Reverse()

        for i = 0, volumeNodes.Count() - 1 do

            local volumeNode = volumeNodes[i]

            local chapterList = ChapterList.New()

            chapterList.AddRange(volumeNode.SelectElements('following-sibling::div/div[contains(@class,"title")]/a'))

            chapterList.Reverse()

            for j = 0, chapterList.Count() - 1 do
                chapters.Add(chapterList[j])
            end

        end

    else

        chapters.AddRange(dom.SelectElements('//div[contains(@class,"list")]//div[contains(@class,"title")]//a'))

        chapters.Reverse()

    end

end

function GetPages()

    BypassMatureContentWarning()

    local currentPage = dom.SelectValue('//div[contains(@class,"current_page")]')

    if(not isempty(currentPage)) then

        for page in Paginator.New(http, dom, '//div[contains(@class,"current_page")]/preceding::div[1]/a/@href') do

            pages.Add(page.SelectValue('//*[@id="page"]//img/@src'))

        end

    else

        if(isempty(pages)) then

            pages.AddRange(dom.SelectValues('//div[@id="page"]//img/@src'))

        end
        
        if(isempty(pages)) then
            
            local pagesJson = GetPagesJson()

            for pageJson in pagesJson.SelectValues('[*]') do

                local pageInfo = Json.New(pageJson)

                local pageUrl = pageInfo.SelectValue('url')

                pages.Add(pageUrl)

            end

        end

    end

end

function GetPagesJson()

    local pagesData = GetAppJs():regex('(\\[.+"\\}\\]);', 1):trim()

    local json = Json.New(pagesData)

    return json

end

function GetAppJs()

    return dom.SelectValue('//script[contains(text(),"var pages")]')

end

function CleanMetadataFieldValue(value)

    -- Empty metadata fields have the value " : ", which should be removed.

    if(tostring(value):trim():startswith(':')) then
        return tostring(value):trim().sub(value, 2)
    end

    return value

end

function BypassMatureContentWarning()

    local isMatureContent = dom.SelectElements('//div[contains(@class, "comic") and contains(@class, "alert")]').Count() > 0

    if(isMatureContent) then

        http.PostData['adult'] = 'true'

        dom = dom.New(http.Post(url))

    end

end
