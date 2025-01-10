require "Madara"

local BaseGetChapters = GetChapters

function Register()

    module.Name = 'Manhastro'
    module.Language = 'pt-br'

    module.Domains.Add('manhastro.com')

end

function GetChapters()

    -- Only a partial list is accessible from the summary page.
    -- We need to access one of the chapters to get a full chapter list.

    local latestChapterUrl = dom.SelectValue('//div[contains(@class,"listing-chapters")]//a/@href')

    if(isempty(latestChapterUrl)) then

        BaseGetChapters()

    else

        dom = Dom.New(http.Get(latestChapterUrl))

        for optionNode in dom.SelectElements('(//select[contains(@class,"single-chapter-select")])[1]//option') do

            local chapterUrl = optionNode.SelectValue('./@data-redirect')
            local chapterTitle = tostring(optionNode)

            chapters.Add(chapterUrl, chapterTitle)

        end

        chapters.Reverse()

    end

end

function GetPages()

    local imagesScript = dom.SelectValue('//script[contains(text(),"imageLinks")]')
    local imagesLinksStr = imagesScript:regex('imageLinks\\s*=\\s*(\\[.+?\\])',  1)
    local imagesLinksJson = Json.New(imagesLinksStr)

    for encodedImageUrl in imagesLinksJson.SelectValues('[*]') do

        local imageUrl = DecodeBase64(encodedImageUrl)

        pages.Add(imageUrl)

    end

end
