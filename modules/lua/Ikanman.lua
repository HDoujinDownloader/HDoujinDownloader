function Register()

    module.Name = '看漫画'
    module.Language = 'Chinese'

    module.Domains.Add('ikanman.com')
    module.Domains.Add('manhuagui.com')

end

function GetInfo()

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

end

function GetChapters()

    local chapterBlocks = dom.SelectElements('//div[contains(@class,"chapter-list")]/ul')

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

    -- The image data is an LZString-compressed base64 string obfuscated using Dean Edward's packer.
    -- A "splic" method is called on the string, which performs the decompression (decompressFromBase64).

    local js = JavaScript.New()

    -- Download the LZString utility. 

    js.Execute(http.Get('https://raw.githubusercontent.com/pieroxy/lz-string/master/libs/lz-string.min.js'))

    -- Add the "splic" method to the string class.

    js.Execute('String.prototype.splic=function(t){return LZString.decompressFromBase64(this).split(t)};')

    -- Unpack the compressed imagedata.

    local packedImageData = tostring(dom):regex('(\\(function\\(p,a,c,k,e,d\\).+?\\)\\)\\s*)<\\/script>', 1)
    local unpackedImageData = tostring(js.Execute(packedImageData))

    -- Generate the image URLs.

    local imageData = Json.New(unpackedImageData:regex('imgData\\(({.+?})\\)', 1))

    for file in imageData.SelectValues('files[*]') do
        pages.Add('https://i.hamreus.com'..tostring(imageData['path'])..file..'?cid='..tostring(imageData['cid'])..'&md5='..tostring(imageData['sl']['m']))
    end

end
