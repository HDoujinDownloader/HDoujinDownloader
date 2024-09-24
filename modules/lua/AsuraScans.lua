function Register()

    module.Name = 'Asura Scans'
    module.Language = 'English'

    module.Domains.Add('asura.gg')
    module.Domains.Add('asura.nacm.xyz')
    module.Domains.Add('asuracomic.net')
    module.Domains.Add('asuracomics.com')
    module.Domains.Add('asuracomics.gg')
    module.Domains.Add('asurascans.com')
    module.Domains.Add('asuratoon.com')
    module.Domains.Add('www.asurascans.com')

    if(API_VERSION >= 20230823) then
        module.DeferHttpRequests = true
    end

end

local function CleanMetadataFieldValue(value)

    -- Empty metadata fields have the value " _ ", which should be blanked out.

    if(tostring(value):trim() == '_') then
        return ""
    end

    return value

end

local function RedirectToNewSeriesUrl()

    -- Series URLs have a random suffix at the end that changes periodically, invalidating bookmarks (#379).
    -- e.g. "/series/serie-title-name-b075e10b"
    -- The random suffix is unique for each series.

    -- For now, just stripping the suffix lets us get the updated series URL.
    -- This works most of the time, but will occassionally result in a 500 error.

    local redirectUrl = RegexReplace(url, '(.+-)([a-z0-9]{8})$', '$1')

    if(API_VERSION >= 20240919) then

        local response = http.GetResponse(redirectUrl)

        if(response.StatusCode == 200) then
            dom = Dom.New(response.Body)
        end

    else

        dom = Dom.New(http.Get(redirectUrl))

    end

end

function GetInfo()

    RedirectToNewSeriesUrl()

    info.Url = url
    info.Title = dom.SelectValue('//span[contains(@class,"text-xl")]')
    info.Description = dom.SelectValue('//h3[contains(text(),"Synopsis")]/following-sibling::span')
    info.Publisher = CleanMetadataFieldValue(dom.SelectValue('//h3[contains(text(),"Serialization")]/following-sibling::h3'))
    info.Author = CleanMetadataFieldValue(dom.SelectValue('//h3[contains(text(),"Author")]/following-sibling::h3'))
    info.Artist = CleanMetadataFieldValue(dom.SelectValue('//h3[contains(text(),"Artist")]/following-sibling::h3'))
    info.Tags = dom.SelectValues('//h3[contains(text(),"Genres")]/following-sibling::div/button')
    info.Status = dom.SelectValue('//h3[contains(text(),"Status")]/following-sibling::h3')
    info.Type = dom.SelectValue('//h3[contains(text(),"Type")]/following-sibling::h3')
    info.Scanlator = 'Asura Scans'

end

function GetChapters()

    RedirectToNewSeriesUrl()

    for chapterNode in dom.SelectElements('//div//a[contains(@class,"block") and contains(@href, "chapter")]') do

        local chapterUrl = chapterNode.SelectValue('@href')
        local chapterTitle = chapterNode.SelectValue('./text()[1]') .. ' ' .. chapterNode.SelectValue('./text()[2]')
        local chapterSubtitle = chapterNode.SelectValue('./span')

        if(not isempty(chapterSubtitle)) then
            chapterTitle = chapterTitle .. ' - ' .. chapterSubtitle
        end

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//img[contains(@src, "comics")]/@src'))

    if(isempty(pages)) then
        pages.AddRange(dom.SelectValues('//img[contains(@alt,"page")]/@src'))
    end

end
