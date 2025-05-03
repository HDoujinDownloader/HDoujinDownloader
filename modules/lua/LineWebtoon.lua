function Register()

    module.Name = 'LINE Webtoon'
    module.Type = 'Webtoon'

    module.Domains.Add('webtoons.com')
    module.Domains.Add('www.webtoons.com')

    -- This cookie is required to access adult content.

    global.SetCookie(module.Domains.First(), 'pagGDPR', 'true')

end

local function GetMotionToonPages()

    local documentUrl = tostring(dom):regex("documentURL:\\s*'([^']+)'", 1)
    local jpgFormat = tostring(dom):regex("\\bjpg:\\s*'([^']+)'", 1):replace('{=filename}', '{0}')
    local pngFormat = tostring(dom):regex("\\bpng:\\s*'([^']+)'", 1):replace('{=filename}', '{0}')
    
    local json = Json.New(http.Get(documentUrl))

    for filename in json.SelectValues('assets.stillcut.*') do

        if(not isempty(pngFormat) and filename:endswith('.png')) then
            filename = FormatString(pngFormat, filename)
        else
            filename = FormatString(jpgFormat, filename)
        end

        pages.Add(filename)

    end

end

function GetInfo()

    -- There are three different areas of the site we need to consider:
    -- https://www.webtoons.com/en/fantasy/the-first-night-with-the-duke/list?title_no=1267 (normal)
    -- https://www.webtoons.com/en/challenge/cherry-comic/list?title_no=8760 (challenge)
    -- https://translate.webtoons.com/webtoonVersion?webtoonNo=468&language=ARA&teamVersion=0&page=2 (translate)

    local tags = {"h1", "h3"} -- Tags to check
    info.Title = ""
    for _, tag in ipairs(tags) do
        local i = 1
        while true do
            local part = dom.SelectValue(string.format('//%s[contains(@class,"subj")]/text()[%d]', tag, i))
            if isempty(part) then break end
            info.Title = string.format('%s %s', info.Title, part)
            i = i + 1
        end
    end
    -- Clean up spaces and trim the result
    info.Title = info.Title:gsub('%s+', ' '):match('^%s*(.-)%s*$')
    
    info.Language = url:regex('\\/([a-z]{2})\\/', 1)
    info.Status = dom.SelectValue('//span[contains(@class,"txt_ico_")]')
    info.Author = dom.SelectValue('//meta[contains(@property,"author")]/@content'):split('/')
    info.Summary = dom.SelectValue('//p[contains(@class,"summary")]')
    info.Tags = dom.SelectValues('//h2[contains(@class,"genre")]')

    if(isempty(info.Language)) then
        info.Language = dom.SelectValue('//p[contains(@class,"flag")]')
    end

    if(isempty(info.Status)) then
        info.Status = dom.SelectValue('//em[contains(@class,"progress_num")]') == '100%' and 'Completed' or 'Ongoing'
    end

    if(isempty(info.Author)) then
        info.Author = dom.SelectValue('//span[contains(@class,"author")]')
    end

    if(isempty(info.Tags)) then
        info.Tags = dom.SelectValues('//p[contains(@class,"genre")]')
    end

    -- Be aware that this chapter count is only a placeholder and not a reliable episode count.
    -- Ex: https://translate.webtoons.com/webtoonVersion?webtoonNo=627&language=SPA&teamVersion=0&page=1

    info.ChapterCount = dom.SelectValue('(//div[contains(@class,"detail_lst")]//span[contains(@class,"tx")])[1]'):trim('#')

    if(isempty(info.ChapterCount)) then
        info.ChapterCount = GetParameter(dom.SelectValue('//div[contains(@class,"detail_lst")]//a[contains(@href,"episodeNo")]/@href'), 'episodeNo')
    end

end

function GetChapters()

    url = SetParameter(url, 'page', 1)
    dom = dom.New(http.Get(url))

    for page in Paginator.New(http, dom, '//div[contains(@class,"paginate")]/a[@href="#"]/following-sibling::a/@href') do
        sleep(500)
        local chapterNodes = page.SelectElements('//div[contains(@class,"detail_lst")]//ul//a[span[contains(@class,"subj")]]')

        for i = 0, chapterNodes.Count() - 1 do

            local chapterUrl = chapterNodes[i].SelectValue('@href')
            local chapterTitle = chapterNodes[i].SelectValue('.//span[contains(@class,"subj")]')

            chapters.Add(chapterUrl, chapterTitle)

        end

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"viewer_lst")]//img/@data-url'))

    -- For motion toons we need to get the images from the API.
    -- Ex: https://www.webtoons.com/en/thriller/chiller/my-name-is-hyunjeong-kim-hyejinyang-last-episode/viewer?title_no=536&episode_no=37

    if(isempty(pages)) then
        GetMotionToonPages()
    end

end
