function Register()
   
    module.Name = 'FoOlSlide'

    module = Module.New()

    module.Language = 'English'

    module.Domains.Add('reader.deathtollscans.net', 'Death Toll Reader')
    module.Domains.Add('zandynofansub.aishiteru.org', 'Zandy no Fansub')
    
    RegisterModule(module)

end

function GetInfo()

    BypassMatureContentWarning()

    info.Title = dom.SelectValue('//h1')
    info.Author = dom.SelectValue('//div[@class="info"]//*[contains(text(), "Author")]/following-sibling::text()'):after(': ')
    info.Artist = dom.SelectValue('//div[@class="info"]//*[contains(text(), "Artist")]/following-sibling::text()'):after(': ')
    info.Summary = dom.SelectValue('//div[@class="info"]//*[contains(text(), "Synopsis")]/following-sibling::text()'):after(': ')
    info.Status = dom.SelectValue('//div[@class="info"]//*[contains(text(), "Status")]/following-sibling::text()'):after(': ')
    info.Tags = dom.SelectValue('//div[@class="info"]//*[contains(text(), "Genre")]/following-sibling::text()'):after(': ')

end

function GetChapters()

    BypassMatureContentWarning()

    chapters.AddRange(dom.SelectElements('//div[@class="list"]//div[@class="title"]/a'))

    chapters.Reverse()

end

function GetPages()

    BypassMatureContentWarning()

    local pageArray = tostring(dom):regex('var\\s*pages\\s*=\\s*(.+?)\\s*;', 1)

    if(pageArray:contains('atob(')) then

        -- Pages are base64 encoded.

        pageArray = DecodeBase64(pageArray:between('atob("', '")'))

    end

    pages.AddRange(Json.New(pageArray).SelectValues('[*].url'))

end

function BypassMatureContentWarning()

    local isMatureContent = dom.SelectElements('//form//input[@name="adult"]').Count() > 0

    if(isMatureContent) then

        http.PostData['adult'] = 'true'

        dom = dom.New(http.Post(url))

    end

end
