function Register()

    module.Name = 'Hentai2Read'
    module.Language = 'english'
    module.Adult = true
    module.Type = 'doujinshi'

    module.Domains.Add('hentai2read.com')

end

function GetInfo()

    if(url:contains('/hentai-list/')) then

        EnqueueAllGalleries()

    else

        info.Title = dom.SelectValue('//h3[contains(@class,"block-title")]/a/text()[1]')
        info.OriginalTitle = dom.SelectValue('//li[contains(@class,"text-muted")]')
        info.Parody = dom.SelectValues('//b[contains(text(),"Parody")]/following-sibling::a')
        info.Status = dom.SelectValues('//b[contains(text(),"Status")]/following-sibling::a')
        info.Author = dom.SelectValues('//b[contains(text(),"Author")]/following-sibling::a')
        info.Artist = dom.SelectValues('//b[contains(text(),"Artist")]/following-sibling::a')
        info.Characters = dom.SelectValues('//b[contains(text(),"Characters")]/following-sibling::a')
        info.Language = dom.SelectValues('//b[contains(text(),"Language")]/following-sibling::a')
        info.Tags = dom.SelectValues('//b[contains(text(),"Category") or contains(text(),"Content")]/following-sibling::a')
        info.Description = dom.SelectValues('//b[contains(text(),"Storyline")]/following-sibling::p')
    
        if(isempty(info.Title)) then
            info.Title = dom.SelectValue('//span[contains(@class,"reader-left-text")]')
        end

    end

end

function GetChapters()

    for chapterNode in dom.SelectElements('//div[contains(@class,"chapter-row")]/following-sibling::a') do

        local chapterUrl = chapterNode.SelectValue('./@href')
        local chapterTitle = chapterNode.SelectValue('./text()[1]')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    local imagesArray = tostring(dom):regex("'images'\\s*:\\s*(\\[.+?\\])", 1)
    local cdnUrl = dom.SelectValue('//img[contains(@id,"arf-reader")]/@src')

    for imageUrl in Json.New(imagesArray) do
        pages.Add(cdnUrl..tostring(imageUrl))
    end

end

function EnqueueAllGalleries()

    for url in dom.SelectValues('//div[contains(@class,"book-grid-item")]/a/@href') do
        Enqueue(url)
    end

    info.Ignore = true

end
