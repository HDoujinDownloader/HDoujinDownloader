function Register()

    module.Name = 'Imperfect Comic'
    module.Language = 'English'
    module.Adult = false

    module.Domains.Add('imperfectcomic.org')

end

local function CleanMetadataFieldValue(value)

    -- Empty metadata fields have the value " - ", which should be blanked out.

    if(tostring(value):trim() == '-') then
        return ""
    end

    return value

end

function GetInfo()

    info.Title = dom.SelectValue('//h1[contains(@class,"entry-title")]')
    info.Summary = dom.SelectValue('//div[contains(@itemprop,"description")]')
    info.AlternativeTitle = dom.SelectValue('//b[contains(text(),"Alternative Titles")]/following-sibling::span')
    info.DateReleased = CleanMetadataFieldValue(dom.SelectValue('//b[contains(text(),"Released")]/following-sibling::span'))
    info.Author = CleanMetadataFieldValue(dom.SelectValue('//b[contains(text(),"Author")]/following-sibling::span'))
    info.Artist = dom.SelectValues('//b[contains(text(),"Artist")]/following-sibling::span')
    info.Tags = dom.SelectValues('//b[contains(text(),"Genres")]/following-sibling::span//a')
    info.Status = dom.SelectValue('//div[contains(text(),"Status")]/i')
    info.Type = dom.SelectValue('//div[contains(text(),"Type")]/a')
    info.Scanlator = 'Imperfect Comic'
    info.Publisher = dom.SelectValue('//b[contains(text(),"Serialization")]/following-sibling::span')

    local chapterCount = dom.SelectValue('//div[@id="chapterlist"]/ul/li[(count(preceding-sibling::*)+1) = 1]/@data-num')

    if(not isempty(chapterCount)) then
        info.ChapterCount = chapterCount
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

    pages.AddRange(dom.SelectValues('//div[@id="readerarea"]//img/@src'))

    -- Make sure to ignore any watermarks (recent chapters only)
    -- if(isempty(pages)) then
    --     pages.AddRange(dom.SelectValues('//div[@id="readerarea"]//img[not(self::node()[not(following-sibling::*)])][(count(preceding-sibling::*)+1)>=4 and ((count(preceding-sibling::*)+1)-4) mod 1=0]/@src'))
    -- end

end
