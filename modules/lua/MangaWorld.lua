function Register()

    module.Name = 'MangaWorld'
    module.Language = 'it'

    module.Domains.Add('mangaworld.ac')
    module.Domains.Add('mangaworld.in')
    module.Domains.Add('mangaworld.nz')
    module.Domains.Add('www.mangaworld.ac')
    module.Domains.Add('www.mangaworld.in')
    module.Domains.Add('www.mangaworld.nz')

    module.Settings.AddCheck('Download by volume', false)
        .WithToolTip('If enabled, manga will be downloaded by volume instead of by chapter.')

end

local function doJavaScriptCookieCheck()

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

local function isDownloadByVolumeEnabled()
    return toboolean(module.Settings['Download by volume'])
end

local function getVolumeNodeByVolumeTitle(volumeTitle)
    return dom.SelectElement('//div[contains(@class,"volume-element") and .//p[contains(.,"' .. volumeTitle .. '")]]')
end

local function getChaptersFromVolumeNode(volumeNode)

    local chaptersXPath = './/a[contains(@class,"chap")]'

    local volumeTitle = volumeNode.SelectValue('.//p')
    local volumeNumber = volumeTitle:regex('0*(\\d+)$', 1)
    local chapterNodes = volumeNode.SelectElements(chaptersXPath)

    local result = {}

    for i = 0, chapterNodes.Count() - 1 do

        local chapterNode = chapterNodes[i]
        local chapter = ChapterInfo.New()

        chapter.Title = chapterNode.SelectValue('span[1]')
        chapter.Url = chapterNode.SelectValue('@href')
        chapter.Volume = volumeNumber

        table.insert(result, chapter)

    end

    return result

end

function GetInfo()

    doJavaScriptCookieCheck()

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

    doJavaScriptCookieCheck()

    -- Note that not all manga will have chapters organized by volume.

    local volumesXPath = '//div[contains(@class,"volume-element")]'
    local chaptersXPath = './/a[contains(@class,"chap")]'

    for volumeNode in dom.SelectElements(volumesXPath) do

        if(isDownloadByVolumeEnabled()) then

            -- Add each volume as a chapter instead.

            local volumeTitle = volumeNode.SelectValue('.//p')
            local volumeUrl = url .. '#' .. volumeTitle

            chapters.Add(volumeUrl, volumeTitle)

        else

            local chapterData = getChaptersFromVolumeNode(volumeNode)

            for i = 1, #chapterData do
                chapters.Add(chapterData[i])
            end

        end

    end

    -- If we fail to find any volumes, just get the chapter list directly instead.

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

    if(isDownloadByVolumeEnabled() and url:contains("#")) then

        -- Add each chapter in this volume as a "page".

        local volumeTitle = url:after("#")
        local volumeNode = getVolumeNodeByVolumeTitle(volumeTitle)
        local chapterData = volumeNode and getChaptersFromVolumeNode(volumeNode)

        if(chapterData) then

            for i = 1, #chapterData do
                pages.Add(chapterData[i].Url)
            end

            return

        end

    else

        -- Get all pages for the current chapter.

        doJavaScriptCookieCheck()

        local baseUrl = dom.SelectValue('//div[contains(@id,"image-loader")]/following-sibling::img/@src')
            :beforelast('/')

        if (not isempty(baseUrl)) then

            -- Get images from the pages array.
            -- We use this method for the "Pagina" view.

            local pagesArray = dom.SelectValue('//script[contains(text(),\'"pages":["\')]')
                :regex('"pages":\\s*(\\[[^\\]]+?\\])', 1)

            for fileName in Json.New(pagesArray) do

                local imageUrl = baseUrl .. '/' .. tostring(fileName)

                pages.Add(imageUrl)
                
            end

        else

            -- Get images directly from the HTML.
            -- We use this method for the "Lista" view.

            pages.AddRange(dom.SelectValues('//img[contains(@id,"page-")]/@src'))

        end

    end

end

function BeforeDownloadPage()

    if(isDownloadByVolumeEnabled() and url:contains('/read/')) then
        GetPages()
    end

end
