function Register()

    module.Name = 'Hentai20.Online'
    module.Adult = true

    module.Domains.Add('hentai20.online')
    module.Domains.Add('mangahentai.io', 'MangaHentai')
    module.Domains.Add('manhwahentai.io', 'ManhwaHentai')
    module.Domains.Add('manytoon.org', 'ManyToon')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Tags = dom.SelectValues('//div[contains(@class,"genres")]//a')
    info.Summary = dom.SelectValue('//div[contains(@itemprop,"description")]')
    info.Type = dom.SelectValue('//div[contains(@class,"meta-item") and contains(text(),"Type")]/span')
    info.Status = dom.SelectValue('//div[contains(@class,"meta-item") and contains(text(),"Status")]/span')
    info.Author = dom.SelectValue('//div[contains(@class,"meta-item") and contains(text(),"Author")]/span')
    info.Artist = dom.SelectValue('//div[contains(@class,"meta-item") and contains(text(),"Artist")]/span')
    info.DateReleased = dom.SelectValue('//div[contains(@class,"meta-item") and contains(text(),"Released")]/span')

end

function GetChapters()

    for chapterNode in dom.SelectElements('//div[contains(@class,"chapter-list")]//a') do

        local chapterUrl = chapterNode.SelectValue('@href')
        local chapterTitle = chapterNode.SelectValue('./div[contains(@class,"chapter-name")]')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    local imageListJs = dom.SelectValue('//script[contains(text(),"read_image_list")]'):regex('read_image_list\\s*=\\s*(\\[.+?\\])', 1)
    local imageListJson = Json.New(imageListJs)

    pages.AddRange(imageListJson.SelectValues('[*]'))

end
