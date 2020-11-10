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

    local chapterNodes = dom.SelectElements('//div[@id="chapters"]/div')
    
    chapterNodes.Reverse()
    
    for chapterNode in chapterNodes do

        local chapterTitle = chapterNode.SelectValue('.//h4')
        local uploadNodes = chapterNode.SelectElements('./following-sibling::ul[1]/li')

        for i=0,uploadNodes.Count() - 1 do

            local chapterInfo = ChapterInfo.New()

            chapterInfo.Title = chapterTitle
            chapterInfo.ScanlationGroup = uploadNodes[i].SelectValue('.//span')
            chapterInfo.Url = uploadNodes[i].SelectValue('.//a/@href')

            chapters.Add(chapterInfo)

        end

    end

end

function GetPages()

    -- Due to the fact the referer isn't carried across HTTPS redirects, the request after the redirect won't have a referer.
    -- A referer is necessary in order to access the images, so a temporary solution is to downgrade to HTTP for the first request. 
    -- The proper solution below will be used after the next update.

    --local redirectUrl = http.GetResponse(url).Url
    local redirectUrl = url:replace('https:', 'http:')

    doc = http.Get(redirectUrl)

    local dirPath = doc:regex("dirPath\\s*=\\s*'(.+?)\'", 1)
    local images = doc:regex("images\\s*=\\s*JSON.parse\\('(.+?)\'", 1)

    for image in Json.New(images).SelectValues('[*]') do
        pages.Add(dirPath..image)
    end

end
