LZStringDownloadUrl = 'https://raw.githubusercontent.com/pieroxy/lz-string/4a94308c1e684fb98866f7ba1288f3db6d9f8801/libs/lz-string.min.js'

function Register()

    module.Name = '看漫画'
    module.Language = 'Chinese'

    module.Domains.Add('ikanman.com')
    module.Domains.Add('manhuagui.com')
    module.Domains.Add('www.manhuagui.com')

end

function GetInfo()

    GetFromMainDomainIfMobileDomain()

    local titleDiv = dom.SelectElement('//div[h1]')
    local subtitle = titleDiv.SelectValue('h2') -- chapters only

    info.Title = titleDiv.SelectValue('h1')

    if(not isempty(subtitle)) then
        info.Title = info.Title..' - '..subtitle
    end

    info.Published = dom.SelectValue('//strong[contains(text(),"出品年代")]/following-sibling::a')
    info.Publisher = dom.SelectValue('//strong[contains(text(),"漫画地区")]/following-sibling::a')
    info.Tags = dom.SelectValues('//strong[contains(text(),"漫画剧情")]/following-sibling::a')
    info.Author = dom.SelectValues('//strong[contains(text(),"漫画剧情")]/following-sibling::a')
    info.Status = dom.SelectValue('//strong[contains(text(),"漫画状态")]/following-sibling::span')
    info.Summary = dom.SelectValue('//div[@id="intro-all"]')
    info.Adult = not isempty(dom.SelectValue('//input[@id="__VIEWSTATE"]'))
    info.Url = url

end

function GetChapters()

    GetFromMainDomainIfMobileDomain()

    local chapterBlocks = GetChapterBlocks()

    for i = 0, chapterBlocks.Count() - 1 do

        local chapterNodes = chapterBlocks[i].SelectElements('li/a[@target]')
        local blockChapters = ChapterList.New()

        for j = 0, chapterNodes.Count() - 1 do

            local chapterUrl = chapterNodes[j].SelectValue('@href')
            local chapterTitle = chapterNodes[j].SelectValue('span/text()')
    
            blockChapters.Add(chapterUrl, chapterTitle)

        end

        blockChapters.Reverse()

        chapters.AddRange(blockChapters)

    end

end

function GetPages()

    GetFromMainDomainIfMobileDomain()

    -- The image data is an LZString-compressed base64 string obfuscated using Dean Edward's packer.
    -- A "splic" method is called on the string, which performs the decompression (decompressFromBase64).

    local js = JavaScript.New()

    -- Download the LZString utility. 

    js.Execute(http.Get(LZStringDownloadUrl))

    -- Add the "splic" method to the string class.

    js.Execute('String.prototype.splic=function(t){return LZString.decompressFromBase64(this).split(t)};')

    -- Unpack the compressed imagedata.

    local packedImageData = tostring(dom):regex('(\\(function\\(p,a,c,k,e,d\\).+?\\)\\)\\s*)<\\/script>', 1)
    local unpackedImageData = tostring(js.Execute(packedImageData))

    -- Generate the image URLs.

    local imageData = Json.New(unpackedImageData:regex('imgData\\(({.+?})\\)', 1))

    for file in imageData.SelectValues('files[*]') do

        local page = PageInfo.New()
        local baseUrl = 'https://i.hamreus.com'..tostring(imageData['path'])..file

        page.Url = baseUrl..'?e='..tostring(imageData['sl']['e'])..'&m='..tostring(imageData['sl']['m'])

        -- Some galleries will accept image URLs with the "cid" and "md5" parameters in additional to the "e" and "m" parameters (the newer format), the latter of which works universally.
        -- We'll add the old format as a backup URL just in case the primary URL doesn't work.

        page.BackupUrls.Add(baseUrl..'?cid='..tostring(imageData['cid'])..'&md5='..tostring(imageData['sl']['m']))

        pages.Add(page)

    end

    -- The referer must be from the domain "www.manhuagui.com", NOT just "manhuagui.com", even though galleries can be accessed through either (otherwise we get a 403).

    pages.Referer = "https://www.manhuagui.com/"

end

function GetFromMainDomainIfMobileDomain()

    if(GetHost(url):startsWith('m.')) then

        url = RegexReplace(url, '\\/\\/m\\.', '//')

        Log("Redirecting to "..url)

        dom = dom.New(http.Get(url))

    end

end

function GetChapterBlocks()

    -- 18+ content has the chapter list stored as an LZString-compressed string in the "__VIEWSTATE" element.
    -- This element will not be present for other content, and the chapters can be read directly.
    
    local rootElement = dom
    local compressedChapterBlocks = dom.SelectValue('//input[@id="__VIEWSTATE"]/@value')

    if(not isempty(compressedChapterBlocks)) then

        local js = JavaScript.New()

        js.Execute(http.Get(LZStringDownloadUrl))

        local uncompressedChapterBlocks = tostring(js.Execute('LZString.decompressFromBase64("'..compressedChapterBlocks..'")'))

        rootElement = Dom.New(uncompressedChapterBlocks)

    end

    return rootElement.SelectElements('//div[contains(@class,"chapter-list")]/ul')

end
