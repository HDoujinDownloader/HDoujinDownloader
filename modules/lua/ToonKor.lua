function Register()

    module.Name = 'ToonKor'
    module.Language = 'Korean'

    module.Domains.Add('tkor.*')
    module.Domains.Add('tkr0*.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//td[contains(@class,"bt_title")]')
    info.Author = dom.SelectValue('//span[contains(text(),"작가")]/following-sibling::span')
    info.Summary = dom.SelectValue('//td[contains(@class,"bt_over")]')

end

function GetChapters()

    for chapterNode in dom.SelectElements('//table[contains(@class,"web_list")]//td[contains(@class,"content__title")]') do

        local chapterUrl = chapterNode.SelectValue('@data-role')
        local chapterTitle = chapterNode.InnerText

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    local imagesStr = tostring(dom):regex("var\\s+toon_img\\s*=\\s*'([^']+)'", 1)
    
    imageStr = DecodeBase64(imagesStr)

    pages.AddRange(Dom.New(imageStr).SelectValues('//img/@src'))

end
