function Register()

    module.Name = 'MangaHub'
    module.Language = 'English'

    module.Domains.Add('mangafox.fun', 'MangaFox.fun')
    module.Domains.Add('mangahere.onl', 'MangaHere.onl')
    module.Domains.Add('mangahub.io', 'MangaHub')
    module.Domains.Add('mangakakalot.fun', 'MangaKakalot.fun')
    module.Domains.Add('mangareader.site', 'MangaReader')

end

function GetInfo()

    info.Title = dom.SelectValue('//*[self::h1 or self::h3]/text()[1]')
    info.AlternativeTitle = dom.SelectValue('//h1/small'):split(';')
    info.Author = dom.SelectValue('//span[contains(text(), "Author")]/following-sibling::span')
    info.Artist = dom.SelectValue('//span[contains(text(), "Artist")]/following-sibling::span')
    info.Status = dom.SelectValue('//span[contains(text(), "Status")]/following-sibling::span')
    info.Tags = dom.SelectValues('//a[contains(@class, "genre-label")]')
    info.Summary = dom.SelectValue('//div[contains(@class, "tab-content")]//p')

end

function GetChapters()

    for node in dom.SelectElements('//li[contains(@class, "list-group-item")]/a') do
        chapters.Add(node.GetAttribute('href'), node.SelectValue('span'))
    end

    chapters.Reverse()

end

function GetPages()

    doc = http.Get(url)

    local apiBase = 'https://api.mghubcdn.com/graphql'
    local cdnBase = 'https://img.mghubcdn.com/file/imghub/'

    local dataSourceKey = GetDataSourceKey()    
    local slug = url:regex('\\/chapter\\/(.+?)\\/', 1)
    local number = url:regex('\\/chapter-(\\d+)$', 1)

    local query = '{"query":"{chapter(x:'..dataSourceKey..',slug:\\"'..slug..'\\",number:'..number..'){pages}}"}'
 
    http.Headers['accept'] = 'application/json'
    http.Headers['content-type'] = 'application/json'

    local response = http.Post(apiBase, query)
    local pagesJson = Json.New(Json.New(response).SelectToken('data.chapter.pages'))

    for pageUrl in pagesJson.SelectValues('*') do
        pages.Add(cdnBase..pageUrl)
    end

end

function GetDataSourceKey()
    
    -- The "dataSourceKey" value is passed along with API requests.
    -- Each affiliated site has an "/assets/client.xxxxxxxx.js" file where the key(s) are defined.

    local dataSourceKey = '' 
    local clientJsPath = doc:regex('\\/assets\\/client\\.\\w+\\.js')
    
    if(not isempty(clientJsPath)) then

        local clientJs = http.Get(clientJsPath)
        local dataSourceKeyPattern = '(?i)domain:"'..GetDomain(url)..'".+?dataSourceKey:"(.+?)"'
        
        dataSourceKey = clientJs:regex(dataSourceKeyPattern, 1)
        
    end

    if(isempty(dataSourceKey)) then
        dataSourceKey = 'm01' -- This is the default for mangahub.io
    end

    return dataSourceKey

end
