function Register()

    module.Name = 'MangaFox'
    module.Language = 'en'

    module.Domains.Add('fanfox.net')
    module.Domains.Add('mangafox.la')
    module.Domains.Add('mangafox.me')

    global.SetCookie(module.Domains.First(), 'isAdult', '1')

end

function GetInfo()

    info.Title = dom.SelectValue('//span[contains(@class,"detail-info-right-title-font")]')
    info.Status = dom.SelectValue('//span[contains(@class,"detail-info-right-title-tip")]')
    info.Author = dom.SelectValues('//p[contains(text(),"Author:")]/a')
    info.Tags = dom.SelectValues('//p[contains(@class,"detail-info-right-tag-list")]/a')
    info.Summary = dom.SelectValues('//p[contains(@class,"fullcontent")]')

    if(isempty(info.Title)) then
        info.Title = CleanTitle(dom.Title)
    end

end

function GetChapters()

    for chapterNode in dom.SelectElements('//div[contains(@id,"chapterlist")]//li') do

        local chapterUrl = chapterNode.SelectValue('.//a/@href')
        local chapterTitle = chapterNode.SelectValue('.//p[contains(@class,"title3")]')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    local imagesScript = JavaScript.Deobfuscate(dom.SelectValue('//script[contains(.,"function(p,a,c,k,e,d)")]'))

    -- There are two ways to get the images-- Sometimes, we access them through the API (chapterfun.ashx).
    -- Other times, the image URLs are right there in the deobfuscated JavaScript.

    if(imagesScript:contains('guidkey')) then

        GetPagesFromChapterFun(imagesScript)

    elseif(imagesScript:contains('newImgs')) then

        local js = JavaScript.New()

        js.Execute(imagesScript)

        local imagesJson = js.GetObject('newImgs').ToJson()

        for imageUrl in imagesJson do
            pages.Add(imageUrl)
        end

    end

end

function CleanTitle(title)

    return tostring(title):before('&#233;')

end

function GetPagesFromChapterFun(imagesScript)

    local js = JavaScript.New()

    js.Execute(imagesScript:split(';')[0])

    local chapterJs = dom.SelectValue('//script[contains(.,"chapterid")]')
    local chapterId = chapterJs:regex('chapterid\\s*=\\s*([^\\s;]+)', 1)
    local imageCount = tonumber(chapterJs:regex('imagecount\\s*=\\s*([^\\s;]+)', 1))
    local pageNumber = 1
    local guidkey = tostring(js.GetObject('guidkey'))

    repeat
        
        -- We won't get a consistent number of pages with each iteration.

        local endpoint = 'chapterfun.ashx?cid=' .. chapterId .. '&page=' .. pageNumber .. '&key=' .. guidkey

        http.Headers['accept'] = '*/*'
        http.Headers['x-requested-with'] = 'XMLHttpRequest'

        local pagesJs = JavaScript.Deobfuscate(http.Get(endpoint))

        js.Execute(pagesJs)

        local imagesJson = js.GetObject('d').ToJson()

        if(imagesJson.Count() <= 0) then
            break
        end

        for imageUrl in imagesJson do
            pages.Add(imageUrl)
        end

        pageNumber = pageNumber + 1

    until (pages.Count() >= imageCount)

end
