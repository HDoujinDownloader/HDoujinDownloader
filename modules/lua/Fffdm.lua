function Register()

    module.Name = '风之动漫'
    module.Language = 'chinese'

    module.Domains.Add('manhua.fffdm.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h2')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//div[@id="content"]//li/a'))

    chapters.Reverse()

end

function GetPages()

    while(true) do

        local nextUrl = dom.SelectValue('//div[contains(@class,"navigation")]/a[contains(text(),"下一页")]/@href')
        
        local imageUrl = dom.SelectValue('//script[contains(text(),"mhurl")]')
            :regex('mhurl\\s*=\\s*"([^"]+)', 1)

        if(isempty(imageUrl)) then
            break
        end

        local imageHost = '//p1.fzacg.com'

        if(not Regex.IsMatch(imageUrl, '2016|2017|2018|2019|2020|2021')) then
            imageHost = '//p5.fzacg.com'
        end

        imageUrl = imageHost .. '/' .. imageUrl

        pages.Add(imageUrl)

        if(isempty(nextUrl) or not nextUrl:contains('index_')) then
            break
        end

        dom = Dom.New(http.Get(url:trim('/') .. '/' .. nextUrl))

    end

end
