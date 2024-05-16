function Register()

    module.Name = 'Manhwa Manga'
    module.Type = 'Webtoon'
    module.Language = 'English'
    module.Adult = true

    module.Domains.Add('manhwamanga.net', 'Manhwa Manga')

end

local function ParsePages()

    local pages = PageList.New()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"chapter-content")]//img/@src'))

    return pages

end

function GetInfo()

    info.Title = dom.SelectValue('//h2')
    info.Summary = dom.SelectValue('//div[contains(@class,"desc-text")]/p')
    info.Artist = dom.SelectValues('//h3[contains(text(),"Artist")]/following-sibling::a')
    info.Tags = dom.SelectValues('//h3[contains(text(),"Genre")]/following-sibling::a')
    info.Status = dom.SelectValues('//h3[contains(text(),"Status")]/following-sibling::a')
    info.OriginalTitle = dom.SelectValues('//h3[contains(text(),"Tag")]/following-sibling::a')

    if(url:contains('/chapter-')) then

        info.Title = dom.Title
        info.PageCount = ParsePages().Count()

    end

end

function GetChapters()

    local totalPages = tonumber(dom.SelectValue('//input[@name="total-page"]/@value')) or 1
    local apiUrl = 'wp-admin/admin-ajax.php'
    local postId = dom.SelectValue('//input[@id="id_post"]/@value')

    for i = 1, totalPages do

        http.PostData.Add('action', 'tw_ajax')
        http.PostData.Add('type', 'pagination')
        http.PostData.Add('id', postId)
        http.PostData.Add('page', i)
        
        local json = Json.New(http.Post(apiUrl))

        dom = Dom.New(json['list_chap'])

        chapters.AddRange(dom.SelectElements('//ul[contains(@class,"list-chapter")]//a'))

    end

end

function GetPages()

    pages.AddRange(ParsePages())

end
