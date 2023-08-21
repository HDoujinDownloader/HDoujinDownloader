function Register()

    module.Name = 'LXHENTAI'
    module.Language = 'vn'
    module.Adult = true

    module.Domains.Add('lxmanga.net')

end

function GetInfo()

    info.Title = dom.SelectValue('//li[@aria-current]//span')
    info.AlternativeTitle = dom.SelectValue('//span[contains(text(),"Tên khác")]/following-sibling::span')
    info.Tags = dom.SelectValues('//span[contains(text(),"Thể loại")]/following-sibling::span//a')
    info.Author = dom.SelectValues('//span[contains(text(),"Tác giả")]/following-sibling::span//a')
    info.Translator = dom.SelectValues('//span[contains(text(),"Nhóm dịch")]/following-sibling::span//a')
    info.Status = dom.SelectValues('//span[contains(text(),"Tình trạng")]/following-sibling::a')

end

function GetChapters()

    for chapterNode in dom.SelectElements('//div[contains(.,"Danh sách chương")]//ul/a') do

        local chapterUrl = chapterNode.SelectValue('./@href')
        local chapterTitle = chapterNode.SelectValue('.//span')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//img[contains(@class,"lazy")]/@src'))

end
