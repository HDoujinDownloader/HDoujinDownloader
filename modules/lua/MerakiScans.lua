function Register()

    module.Name = 'Meraki Scans'
    module.Language = 'English'

    module.Domains.Add('merakiscans.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//*[@id="manga_name"]')
    info.Language = dom.SelectValue('//*[@id="flag_image"]/@alt')
    info.AlternativeTitle = dom.SelectValue('//li[contains(text(),"Alt Name(s):")]'):after(':')
    info.DateReleased = dom.SelectValue('//li[contains(text(),"Release Year:")]'):after(':')
    info.Author = dom.SelectValue('//li[contains(text(),"Author:")]'):after(':')
    info.Artist = dom.SelectValue('//li[contains(text(),"Artist:")]'):after(':')
    info.Status = dom.SelectValue('//li[contains(text(),"Status:")]'):after(':')
    info.Tags = dom.SelectValues('//a[@id="genre_link"]')
    info.Summary = dom.SelectValue('(//div[contains(@id,"content2")]//span)[last()]')
    info.Scanlator = module.Name

    if(isempty(info.Title)) then
        info.Title = dom.SelectValue('//h1')
    end

end

function GetChapters()

    for chapterNode in dom.SelectElements('//tr[contains(@id,"chapter-head")]') do

        local chapterUrl = chapterNode.SelectValue('@data-href')
        local chapterTitle = chapterNode.SelectValue('./td')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    local readerScript = dom.SelectValue('//script[contains(text(), "maxPageCount")]')

    local filenames = Json.New(readerScript:regex('var\\s*images\\s*=\\s*(\\[.+?\\]);', 1)).SelectValues('[*]')
    local currentChapter = readerScript:regex('var\\s*currentChapter\\s*=\\s*"(.+?)";', 1);
    local mangaSlug = readerScript:regex('var\\s*manga_slug\\s*=\\s*"(.+?)";', 1);

    for filename in filenames do

        local pageUrl = '/manga/' .. mangaSlug .. '/' .. currentChapter .. '/' .. filename

        pages.Add(pageUrl)

    end

end
