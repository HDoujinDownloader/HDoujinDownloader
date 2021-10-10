function Register()

    module.Name = 'Manga18.club'
    module.Language = 'Chinese'
    module.Adult = true

    module.Domains.Add('manga18.club')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Author = dom.SelectValues('//div[contains(@class,"info_label") and contains(text(),"Author")]/following-sibling::div//a')
    info.Artist = dom.SelectValues('//div[contains(@class,"info_label") and contains(text(),"Artist")]/following-sibling::div//a')
    info.Status = dom.SelectValues('//div[contains(@class,"info_label") and contains(text(),"Status")]/following-sibling::div//a')
    info.Tags = dom.SelectValues('//div[contains(@class,"info_label") and contains(text(),"Categories")]/following-sibling::div//a')
    info.Summary = dom.SelectValue('//div[contains(@class,"detail_reviewContent")]')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//div[contains(@class,"chapter_box")]//a[contains(@class,"chapter_num")]'))

    chapters.Reverse()

end

function GetPages()

    local imagesArray = dom.SelectValue('//script[contains(text(),"slides_p_path")]')
        :regex('slides_p_path\\s*=\\s*(\\[[^\\]]+\\])', 1)

    for encodedImageUrl in Json.New(imagesArray).SelectValues('[*]') do
        pages.Add(DecodeBase64(encodedImageUrl))
    end

end
