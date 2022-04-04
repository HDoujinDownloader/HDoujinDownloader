function Register()

    module.Name = 'Flatsome'

    module = Module.New()

    module.Language = 'Vietnamese'

    module.Domains.Add('truyenkinhdien.com', 'Truyện kinh điển')

    RegisterModule(module)

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.AlternativeTitle = dom.SelectValue('//li[contains(text(),"Tên khác")]/span'):split(',')
    info.Status = dom.SelectValue('//ul[contains(.,"T&igrave;nh trạng")]/following-sibling::div//a')
    info.Tags = dom.SelectValues('//ul[contains(.,"Thể loại")]/following-sibling::div//a')
    info.Author = dom.SelectValues('//ul[contains(.,"T&aacute;c giả")]/following-sibling::div//a')
    info.Summary = dom.SelectValues('//div[contains(@id,"tab-description")]//p'):join('\n\n')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//span[contains(@class,"comic-archive-title")]/a'))

end

function GetPages()

    local hash = dom.SelectValue('//div/@data-sgdg-hash')
    local page = 1
    local endpoint = '/wp-admin/admin-ajax.php?action=gallery&hash=' .. hash .. '&path=&page='

    http.Headers['accept'] = '*/*'
    http.Headers['x-requested-with'] = 'XMLHttpRequest'

    while (true) do

        local jsonStr = http.Get(endpoint .. page)

        if(isempty(jsonStr)) then
            break
        end

        local json = Json.New(jsonStr)
        local imageUrls = json.SelectValues('images[*].image')
        local moreImages = toboolean(json.SelectValue('more'))

        pages.AddRange(imageUrls)

        if(imageUrls.Count() <= 0 or not moreImages) then
            break
        end

        page = page + 1

    end

end
