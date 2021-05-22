function Register()

    module.Name = 'BlogTruyen'
    module.Language = 'Vietnamese'

    module.Domains.Add('blogtruyen.vn')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1[contains(@class,"entry-title")]')
    info.Summary = dom.SelectValue('//div[@class="content"]')
    info.AlternativeTitle = dom.SelectValue('//p[contains(text(),"Tên khác")]/span'):split(',')
    info.Author = dom.SelectValues('//p[contains(text(),"Tác giả")]/a')
    info.Translator = dom.SelectValues('//p[contains(text(),"Nhóm dịch")]/span')
    info.Tags = dom.SelectValues('//p[contains(text(),"Thể loại")]//a')
    info.Status = dom.SelectValues('//p[contains(.,"Trạng thái")]/span[last()]')

    if(isempty(info.Title)) then
        info.Title = dom.SelectValue('//h1')
    end

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//p[contains(@id,"chapter")]//a'))

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//article/img/@src'))

end
