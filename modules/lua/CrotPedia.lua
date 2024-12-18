function Register()

    module.Name = 'CrotPedia'
    module.Language = 'Indonesian'
    module.Adult = true

    module.Domains.Add('38.242.194.12')
    module.Domains.Add('158.220.106.212')
    module.Domains.Add('crotpedia.net')

    module = Module.New()

    module.Language = 'Thai'

    module.Domains.Add('germa-66.com', 'Germa-66')
    module.Domains.Add('oremanga.net', 'Oremanga')
    module.Domains.Add('skoiiz-manga.com', 'skoiiz-manga')
    module.Domains.Add('www.oremanga.net', 'Oremanga')

end

function GetInfo()

    info.Title = dom.SelectValue('//div[contains(@class,"series-title")]/h2')
    info.OriginalTitle = dom.SelectValue('//div[contains(@class,"series-title")]/span')
    info.Tags = dom.SelectValues('//div[contains(@class,"series-genres")]//a')
    info.Description = dom.SelectValue('//div[contains(@class,"series-synops")]')
    info.Type = dom.SelectValue('//div[contains(@class,"series-info")]/span[contains(@class,"type")]')
    info.Status = dom.SelectValue('//div[contains(@class,"series-info")]/span[contains(@class,"status")]')
    info.AlternativeTitle = dom.SelectValue('//ul[contains(@class,"series-infolist")]//b[contains(text(),"Alternative")]//following-sibling::span')
    info.Author = dom.SelectValue('//ul[contains(@class,"series-infolist")]//b[contains(text(),"Author")]//following-sibling::span')
    info.DateReleased = dom.SelectValue('//ul[contains(@class,"series-infolist")]//b[contains(text(),"Published")]//following-sibling::span')

end

function GetChapters()

    for chapterNode in dom.SelectElements('//ul[contains(@class,"chapterlist")]//div[contains(@class,"flexch-infoz")]//a') do

        local chapterUrl = chapterNode.SelectValue('./@href')
        local chapterTitle = chapterNode.SelectValue('./span/text()[1]')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"reader-area")]//img/@src'))

    if(isempty(pages)) then

        -- Oremanga uses canvases.
        -- The JS used to unscramble each image directly follows each canvas.

        local imageUrls = dom.SelectValues('//div[contains(@class,"reader-area")]//canvas/@data-url')
        local unscrambleJs = dom.SelectValues('//div[contains(@class,"reader-area")]//canvas/following-sibling::script')

        for i = 0, imageUrls.Count() - 1 do

            local page = PageInfo.New(imageUrls[i])

            page.Data['unscrambleJs'] = unscrambleJs[i]

        end

    end

end

function AfterDownloadPage()

    local unscrambleJs = page.Data['unscrambleJs']

    if(isempty(unscrambleJs)) then
        return
    end

    unscrambleJs = JavaScript.Deobfuscate(unscrambleJs)

    local unscrambler = ImageUnscrambler.New(args.Image)
    local unscrambleJson = Json.New(unscrambleJs:regex('sovleImage\\s*=\\s*(\\[.+?]);', 1))

    local piecesX = 2
    local piecesY = 5
    local pieceW = args.Image.Width / piecesX
    local pieceH = args.Image.Height / piecesY

    for pieceJson in unscrambleJson.SelectTokens('[*]') do

        local destX = tonumber(pieceJson.SelectValue('[0]'))
        local destY = tonumber(pieceJson.SelectValue('[1]'))
        local srcX = tonumber(pieceJson.SelectValue('[2]'))
        local srcY = tonumber(pieceJson.SelectValue('[3]'))
        local srcW = pieceW
        local srcH = pieceH

        unscrambler.Copy(srcX, srcY, srcW, srcH, destX, destY)

    end

    unscrambler.Save()

end
