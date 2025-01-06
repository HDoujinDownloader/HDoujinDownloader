function Register()

    module.Name = 'LectorManga'
    module.Language = 'Spanish'
    module.Type = 'Manga'

    module.Domains.Add('lectormanga.com', 'LectorManga')
    module.Domains.Add('followmanga.com', 'FollowManga')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1/text()')
    info.DateReleased = dom.SelectValue('//h1/small'):between('(', ')')
    info.Type = dom.SelectValue('//h5[contains(text(),"Tipo")]/span')
    info.Status = dom.SelectValue('//h5[contains(text(),"Estado")]/span')
    info.Tags = dom.SelectValues('//h5[contains(text(),"Géneros")]//following-sibling::a')
    info.AlternativeTitle = dom.SelectValues('//h5[contains(text(),"Títulos alternativos")]//following-sibling::span')

end

function GetChapters()

    local chapterNodes = dom.SelectElements('//div[@id="chapters" or @id="chapters-collapsed"]/div')

    chapterNodes.Reverse()

    for chapterNode in chapterNodes do

        local chapterTitle = chapterNode.SelectValue('.//h4')
        local uploadNodes = chapterNode.SelectElements('./following-sibling::ul[1]/li')

        for i = 0, uploadNodes.Count() - 1 do

            local chapterInfo = ChapterInfo.New()

            chapterInfo.Title = chapterTitle
            chapterInfo.ScanlationGroup = uploadNodes[i].SelectValue('.//span')
            chapterInfo.Url = uploadNodes[i].SelectValue('.//a[contains(@class,"btn-default")]/@href')

            chapters.Add(chapterInfo)

        end

    end

end

function GetPages()

    -- Getting the final chapter URL is a multi-step process.
    -- The chapter URL bring us to a page that POSTs an endpoint to get the final chapter URL.

    dom = Dom.New(http.Get(url))

    -- Make the POST request to get the final chapter URL.

    local postScript = dom.SelectValue('//script[contains(text(), "params")]')
    local postEndpoint = postScript:regex("form\\.action\\s*=\\s*'([^']+)", 1):trim('/') .. '/'
    local postParams = postScript:regex('const\\s*params\\s*=\\s*({.+?})', 1)
    local postParamsJson = Json.New(postParams)

    for key in postParamsJson.Keys do
        http.PostData[key] = tostring(postParamsJson[key])
    end

    dom = dom.New(http.Post(postEndpoint))

    -- Extract the chapter URL from the redirect script.

    local redirectScript = dom.SelectValue('//script[contains(text(), "window.location")]')
    local redirectEndpoint = redirectScript:regex("window\\.location\\.replace\\('([^']+)", 1)
    local redirectReferer = GetRoot(redirectEndpoint)

    http.Headers['origin'] = 'https://' .. module.Domain
    http.Headers['referer'] = redirectReferer

    dom = dom.New(http.Get(redirectEndpoint))

    -- Finally, extract the page list.

    local readerScript = dom.SelectValue('//script[contains(text(),"dirPath")]')

    local dirPath = readerScript:regex("dirPath\\s*=\\s*'(.+?)\'", 1)
    local images = readerScript:regex("images\\s*=\\s*JSON.parse\\('(.+?)\'", 1)

    pages.Referer = redirectReferer

    for image in Json.New(images).SelectValues('[*]') do
        pages.Add(dirPath .. image)
    end

end
