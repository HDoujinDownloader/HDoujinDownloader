function Register()
   
    module.Name = 'TruyenVN'
    module.Language = 'Vietnamese'

    module.Domains.Add('truyenvn.com')
    
end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Author = dom.SelectValue('//span[contains(text(),"Tác giả")]/following-sibling::a')
    info.Status = dom.SelectValue('//span[contains(text(),"Tình trạng")]/following-sibling::text()')
    info.Tags = dom.SelectValues('//div[contains(@class,"genre")]/a')
    info.Summary = dom.SelectValue('//strong[contains(text(),"Cảnh báo độ tuổi:")]/following-sibling::text()')

end

function GetChapters()

    for chapterNode in dom.SelectElements('//*[@id="chapterList"]//a') do

        local chapterUrl = chapterNode.SelectValue('@href')
        local chapterTitle = chapterNode.SelectValue('span[1]')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    http.Referer = url

    http.Headers['accept'] = 'application/json, text/javascript, */*; q=0.01'
    http.Headers['content-type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
    http.Headers['x-requested-with'] = 'XMLHttpRequest'

    http.PostData['action'] = 'z_do_ajax'
    http.PostData['_action'] = 'load_imgs_for_chapter'
    http.PostData['p'] = dom.SelectValue('//input[@name="p"]/@value')

    local json = Json.New(http.Post('/wp-admin/admin-ajax.php'))

    pages.AddRange(json.SelectValues('mes[*].url'))

end
