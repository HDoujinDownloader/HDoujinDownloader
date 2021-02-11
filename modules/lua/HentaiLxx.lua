function Register()

    module.Name = 'HentaiLXX'
    module.Language = 'Vietnamese'
    module.Adult = true

    module.Domains.Add('hentailxx.com', 'HentaiLXX')
    module.Domains.Add('lxhentai.com', 'Hentailxx.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Author = dom.SelectValues('//div[contains(text(),"Tác giả")]/following-sibling::div[1]/a')
    info.Status = dom.SelectValue('//div[contains(text(),"Tình trạng")]/following-sibling::div')
    info.Tags = dom.SelectValues('//div[*[contains(@class,"fa-tags")] and contains(text(),"Thể loại")]/following-sibling::div/a')
    info.Summary = dom.SelectValue('//p')

    -- Get the title from the reader.

    if(isempty(info.Title)) then
        info.Title = dom.SelectValue('//h4')
    end

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//div[@id="listChuong"]//a'))    

    chapters.Reverse()

end

function GetPages()

    -- The "not(@target)" part is there to avoid downloading the ad image at the end of the post.

    pages.AddRange(dom.SelectValues('//div[@id="content_chap"]//img[not(@target)]/@src'))

end
