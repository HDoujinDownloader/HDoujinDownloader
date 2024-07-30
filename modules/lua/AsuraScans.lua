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

local function RedirectToNewSerieUrl()

    -- For some serie, the path looks like like this:
    -- /series/serie-title-name-b075e10b
    -- That numeric suffix unique id could change occassionally, breaking existing URLs in bookmarks or the download queue.
    -- If we hit a 404 page for a serie URL, attempt to find the current alphanumeric ID and update the URL.
    -- See https://github.com/HDoujinDownloader/HDoujinDownloader/issues/158

end

function GetInfo()

    RedirectToNewSerieUrl()

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

    RedirectToNewSerieUrl()

    for chapterNode in dom.SelectElements('//div//a[contains(@class,"block") and contains(@href, "chapter")]') do

        local chapterUrl = chapterNode.SelectValue('@href')
        local chapterTitle = chapterNode.SelectValue('.')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//img[contains(@src, "comics")]/@src'))

end
