function Register()

    module.Name = 'MangaWorld'
    module.Language = 'it'

    module.Domains.Add('mangaworld.ac')
    module.Domains.Add('mangaworld.in')
    module.Domains.Add('mangaworld.nz')
    module.Domains.Add('www.mangaworld.ac')
    module.Domains.Add('www.mangaworld.in')
    module.Domains.Add('www.mangaworld.nz')

end

local function DoJavaScriptCookieCheck()

    local aesScriptUrl = '/aes.min.js'
    local cookieScript = dom.SelectValue('//script[contains(text(),"slowAES")]')

    if(not isempty(cookieScript)) then

        local js = JavaScript.New()

        js.Execute(http.Get(aesScriptUrl))
        js.Execute('document = location = {}')
        js.Execute(cookieScript)

        local cookiesStr = js.GetObject('document.cookie').ToString()
        local redirectUrl = js.GetObject('location.href').ToString()
        local mwCookieValue = cookiesStr:regex('MWCookie=([^;,\\s]+)', 1)

        http.Cookies['MWCookie'] = mwCookieValue

        dom = Dom.New(http.Get(redirectUrl))

    end

end

function GetInfo()

    DoJavaScriptCookieCheck()

    info.Title = dom.SelectValue('//h1')
    info.AlternativeTitle = dom.SelectValue('//span[contains(text(),"Titoli alternativi")]/following-sibling::text()'):split(',')
    info.Tags = dom.SelectValues('//span[contains(text(),"Generi")]/following-sibling::a')
    info.Author = dom.SelectValues('//span[contains(text(),"Autore") or contains(text(),"Autori")]/following-sibling::a')
    info.Artist = dom.SelectValues('//span[contains(text(),"Artisti")]/following-sibling::a')
    info.Type = dom.SelectValue('//span[contains(text(),"Tipo")]/following-sibling::a')
    info.Status = dom.SelectValue('//span[contains(text(),"Stato")]/following-sibling::a')
    info.DateReleased = dom.SelectValue('//span[contains(text(),"Anno di uscita")]/following-sibling::a')
    info.Translator = dom.SelectValue('//span[contains(text(),"Fansub")]/following-sibling::a')
    info.Summary = dom.SelectValue('//div[@id="noidungm"]')

end

function GetChapters()

    DoJavaScriptCookieCheck()

    -- Note that not all manga will have chapters organized by volume.

    local volumesXPath = '//div[contains(@class,"volume-element")]'
    local chaptersXPath = './/a[contains(@class,"chap")]'

    for volumeNode in dom.SelectElements(volumesXPath) do

        local volumeNumber = volumeNode.SelectValue('.//p'):regex('0*(\\d+)$', 1)
        local chapterNodes = volumeNode.SelectElements(chaptersXPath)

        for i = 0, chapterNodes.Count() - 1 do

            local chapterNode = chapterNodes[i]
            local chapter = ChapterInfo.New()


            chapter.Title = chapterNode.SelectValue('span[1]')
            chapter.Url = chapterNode.SelectValue('@href')
            chapter.Volume = volumeNumber

            chapters.Add(chapter)

        end

    end

    if(isempty(chapters)) then

        for chapterNode in dom.SelectElements('//div[contains(@class,"chapters-wrapper")]/' .. chaptersXPath) do

            local chapterTitle = chapterNode.SelectValue('span[1]')
            local chapterUrl = chapterNode.SelectValue('@href')

            chapters.Add(chapterUrl, chapterTitle)

        end

    end

    chapters.Reverse()

end

function GetPages()

    DoJavaScriptCookieCheck()

    local baseUrl = dom.SelectValue('//div[contains(@id,"image-loader")]/following-sibling::img/@src')
        :beforelast('/')

    if(isempty(baseUrl)) then
        return
    end

    local pagesArray = dom.SelectValue('//script[contains(text(),\'"pages":["\')]')
        :regex('"pages":\\s*(\\[[^\\]]+?\\])', 1)

    for filename in Json.New(pagesArray) do

        local imageUrl = baseUrl .. '/' .. tostring(filename)

        pages.Add(imageUrl)

    end

end
