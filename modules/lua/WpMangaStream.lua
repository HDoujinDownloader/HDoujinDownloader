-- MangaStream is a WordPress theme.
-- https://themesia.com/mangastream-wordpress-theme/

function Register()

    module.Name = 'MangaStream'
    module.Language = 'English'

    module.Domains.Add('asurascans.com', 'Asura Scans')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1[contains(@class,"entry-title")]')
    info.Description = dom.SelectValue('//div[contains(@itemprop,"description")]')
    info.DateReleased = CleanMetadataFieldValue(dom.SelectValue('//b[contains(text(),"Released")]/following-sibling::span'))
    info.Author = CleanMetadataFieldValue(dom.SelectValue('//b[contains(text(),"Author")]/following-sibling::span'))
    info.Tags = dom.SelectValues('//b[contains(text(),"Genres")]/following-sibling::span//a')
    info.Status = dom.SelectValue('//div[contains(text(),"Status")]/i')
    info.Type = dom.SelectValue('//div[contains(text(),"Type")]/a')

    if(module.GetName(url):endsWith('Scans')) then
        info.Scanlator = module.GetName(url)
    end

end

function GetChapters()

    for chapterNode in dom.SelectElements('//div[@id="chapterlist"]//a') do

        local chapterUrl = chapterNode.SelectValue('@href')
        local chapterTitle = chapterNode.SelectValue('span')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[@id="readerarea"]//img/@data-src'))

end

function CleanMetadataFieldValue(value)

    -- Empty metadata fields have the value " - ", which should be blanked out.

    if(tostring(value):trim() == '-') then
        return ""
    end

    return value

end
