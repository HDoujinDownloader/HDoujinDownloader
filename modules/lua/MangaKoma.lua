local function getApiJson(endpoint)

    http.Headers['x-requested-with'] = 'XMLHttpRequest'

    local responseData = http.Get(endpoint)

    -- We'll occassionally get malformed JSON of the form:

    -- The requested URL returned error: 403{
    --     ...
    -- }

    -- Despite the "error", the actual JSON content is still valid.

    responseData = responseData:regex('{.+}')

    return Json.New(responseData)

end

local function getChapterId()
    return dom.SelectValue('//script[contains(text(),"CHAPTER_ID")]'):regex('CHAPTER_ID\\s*=\\s*(\\d+)', 1)
end

local function getReaderJson()

    local chapterId = getChapterId()
    local endpoint = '/ajax/image/list/chap/' .. chapterId

    return getApiJson(endpoint)

end

function Register()

    module.Name = 'Manga Koma'
    module.Language = 'jp'

    module.Domains.Add('mangakoma01.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Tags = dom.SelectValues('//div[@id="main"]//a[@rel="tag" and contains(@href, "/genres/")]')
    info.Summary = dom.SelectValue('//div[contains(@id,"syn-target")]')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//li[contains(@class,"chapter")]//a'))

    chapters.Reverse()

end

function GetPages()

    local json = getReaderJson()

    for imageUrl in Dom.New(json.SelectValue('html')).SelectValues('//a[contains(@class,"readImg")]//img/@src') do

        if(not imageUrl:contains('/rawwkuro.jpg')) then
            pages.Add(imageUrl)
        end

    end

end
