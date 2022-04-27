function Register()

    module.Name = 'Japanread'
    module.Language = 'french'

    module.Domains.Add('japanread.cc')
    module.Domains.Add('www.japanread.cc')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.AlternativeTitle = dom.SelectValue('//div[contains(text(),"Nom alternatif")]/following-sibling::div')
    info.Author = dom.SelectValues('//div[contains(text(),"Auteur")]/following-sibling::div//a')
    info.Artist = dom.SelectValues('//div[contains(text(),"Artiste")]/following-sibling::div//a')
    info.DateReleased = dom.SelectValue('//div[contains(text(),"Année")]/following-sibling::div')
    info.Status = dom.SelectValue('//div[contains(text(),"Statut")]/following-sibling::div')
    info.Tags = dom.SelectValues('//div[contains(text(),"Catégories")]/following-sibling::div/a')
    info.Summary = dom.SelectValue('//div[contains(text(),"Description")]/following-sibling::div')

end

function GetChapters()

    for page in Paginator.New(http, dom, '//a[@rel="next"]/@href') do
    
        local chapterNodes = page.SelectElements('//div[contains(@data-row,"chapter")]')

        for i = 0, chapterNodes.Count() - 1 do

            local chapterNode = chapterNodes[i]
            local chapterInfo = ChapterInfo.New()

            chapterInfo.Url = chapterNode.SelectValue('.//a/@href')
            chapterInfo.Title = chapterNode.SelectValue('.//span[contains(@class,"manga_nb_chapter")]')
            chapterInfo.Scanlator = chapterNode.SelectValue('.//div[contains(@class,"chapter-list-group")]')
           
            local chapterSubtitle = chapterNode.SelectValue('.//span[contains(@class,"manga_title")]')

            if(not isempty(chapterSubtitle)) then
                chapterInfo.Title = chapterSubtitle .. ' - ' .. chapterSubtitle
            end

            chapters.Add(chapterInfo)

        end
    
    end

    chapters.Reverse()

end

function GetPages()

    local json = GetChapterJson()

    local baseImageUrl = json.SelectValue('baseImagesUrl')

    for imageUrl in json.SelectValues('page_array[*]') do
        pages.Add(baseImageUrl .. '/' .. imageUrl)
    end

end

local function GetApiUrl()

    return 'api/'

end

local function GetApiJson(endpoint)

    http.Headers['accept'] = 'application/json, text/plain, */*'
    http.Headers['x-requested-with'] = 'XMLHttpRequest'
    http.Headers['a'] = JavaScript.New().Execute('Math.random().toString(16).substr(2, 12)') 

    return Json.New(http.Get(GetApiUrl() .. endpoint))

end

function GetChapterJson()

    local chapterId = dom.SelectValue('//meta/@data-chapter-id')

    return GetApiJson('?id=' .. chapterId .. '&type=chapter')

end
