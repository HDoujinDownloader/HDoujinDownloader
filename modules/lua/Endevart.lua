function Register()

    module.Name = 'Endevart'

    module.Domains.Add('endevart.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Language = dom.SelectValue('//span[contains(@class,"badge-success")]')
    info.Tags = dom.SelectValues('//a[contains(@href,"/genre/")]/span[contains(@class,"badge-primary")]')
    info.Author = dom.SelectValue('//div[h4[contains(text(),"Authors")]]/following-sibling::div//span')
    info.Artist = dom.SelectValue('//div[h4[contains(text(),"Artists")]]/following-sibling::div//span')
    info.Status = dom.SelectValue('//div[h4[contains(text(),"Status")]]/following-sibling::div//span')
    info.AlternativeTitle = dom.SelectValue('//div[h4[contains(text(),"Alt. Names")]]/following-sibling::div//p'):split(',')

end

function GetChapters()

    local comicId = url:regex('\\/comic\\/([^\\/?#]+?)$', 1)
    local chaptersPerPage = 50
    local currentPage = 1

    while true do

        local payload = '{"path":"/api/chapter/","query":{"page_size":' .. chaptersPerPage .. ',"page":' .. currentPage .. ',"comic":"' .. comicId .. '","ordering":"number","expand":"~all","fields":"id,published_at,language,language_name,name,cstr_full,short_name_full,oneshot,number,number.cstr,chapter_number"},"headers":{}}'
        local json = GetApiJson(payload)

        local count = tonumber(json.SelectValue('count'))

        for chapterNode in json.SelectTokens('results[*]') do

            local chapterId = chapterNode.SelectValue('id')

            local chapterInfo = ChapterInfo.New()

            chapterInfo.Url = '/chapter/' .. chapterId
            chapterInfo.Title = chapterNode.SelectValue('cstr_full')
            chapterInfo.Language = chapterNode.SelectValue('language_name')

            chapters.Add(chapterInfo)

        end

        if(isempty(count) or chapters.Count() >= count) then
            break
        end

        currentPage = currentPage + 1

    end

    chapters.Reverse()

end

function GetPages()

    local js = JavaScript.New()
    local comicJavaScript = dom.SelectValue('//script[contains(text(), "window.__NUXT__")]')

    js.Execute('window = {}')
    js.Execute(comicJavaScript)

    local comicJson = js.GetObject('window.__NUXT__').ToJson()

    pages.AddRange(comicJson.SelectValues('..pages[*].image'))

end

function GetApiEndpoint()

    return '/api/__api_party/party'

end

function GetApiJson(payload)

    http.Headers['accept'] = 'application/json'
    http.Headers['content-type'] = 'application/json'

    local endpoint = GetApiEndpoint()

    return Json.New(http.Post(endpoint, payload))

end
