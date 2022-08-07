function Register()

    module.Name = "ReadMangaToday"
    module.Language = 'English'

    module.Domains.Add('readmanga.today')
    module.Domains.Add('readmng.com')
    module.Domains.Add('www.readmng.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.AlternativeTitle = dom.SelectValue('//dt[contains(text(), "Alternative Name")]/following-sibling::dd')
    info.Status = dom.SelectValue('//dt[contains(text(), "Status")]/following-sibling::dd')
    info.Tags = dom.SelectValues('//dt[contains(text(), "Categories")]/following-sibling::*[1]/a')
    info.Type = dom.SelectValue('//dt[contains(text(), "Type")]/following-sibling::dd')
    info.Summary = dom.SelectValue('//li[contains(@class, "movie-detail")]/p')
    info.Author = dom.SelectValue('//li[contains(text(), "Author")]/preceding-sibling::li')
    info.Artist = dom.SelectValue('//li[contains(text(), "Artist")]/preceding-sibling::li')
 
    if(isempty(info.Title)) then
        info.Title = tostring(dom.Title):after(' - Read'):trim()
    end

end

function GetChapters()

    for node in dom.SelectElements('//ul[contains(@class, "chp_lst")]/li/a') do
        chapters.Add(node.GetAttribute('href'), node.ChildNodes[1])
    end

    if(isempty(chapterNodes)) then -- readmng.com

        for node in dom.SelectElements('//a[contains(@class,"chnumber")]') do
            chapters.Add(node.GetAttribute('href'), node.SelectValue('.//text()[1]'))
        end

    end

    chapters.Reverse()

end

function GetPages()
    
    local doc = http.Get(url)
    local imagesArray = doc:regex('var\\s*images\\s*=\\s*(\\[.+?\\])', 1)

    if(isempty(imagesArray)) then -- readmng.com
        imagesArray = doc:regex('"images":\\s*(\\[.+?\\])', 1)
    end

    local pagesJson = Json.New(imagesArray)

    pages.AddRange(pagesJson.SelectTokens('[*].url'))

    if(isempty(pages)) then -- readmng.com
        pages.AddRange(pagesJson.SelectTokens('[*]')) 
    end

    for page in pages do 
        
        -- Newer chapters uploaded after April 1st, 2020 can contain images with malformed URLs (starting with "https:///").
        -- Version 1.19.9.32-r.9+ can handle this situation automatically, but it's fixed manually here for backwards compatibility.

        page.Url = RegexReplace(page.Url, '(?<=^https?:\\/\\/)\\/+', '')

    end

end
