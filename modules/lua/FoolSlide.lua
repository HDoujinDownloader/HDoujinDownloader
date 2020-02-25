function Register()
   
    module.Name = 'FoOlSlide'

    module.Domains.Add('jaiminisbox.com', 'Jaimini\'s Box')
    
end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Author = dom.SelectValue('//div[@class="info"]/*[contains(text(), "Author")]/following-sibling::text()'):after(': ')
    info.Artist = dom.SelectValue('//div[@class="info"]/*[contains(text(), "Artist")]/following-sibling::text()'):after(': ')
    info.Summary = dom.SelectValue('//div[@class="info"]/*[contains(text(), "Synopsis")]/following-sibling::text()'):after(': ')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//div[@class="list"]//div[@class="title"]/a'))

    chapters.Reverse()

end

function GetPages()

    local doc = http.Get(url)
    local pageContent = doc:regex('var\\s*pages\\s*=\\s*(.+?)\\s*;', 1)

    if(pageContent:contains('atob(')) then

        -- Pages are base64 encoded.

        pageContent = DecodeBase64(pageContent:between('atob("', '")'))

    end

    pages.AddRange(Json.New(pageContent).SelectValues('[*].url'))

end
