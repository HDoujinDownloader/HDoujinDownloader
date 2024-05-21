function Register()

    module.Name = 'MangaPark'
    module.Language = 'English'

end

local function IsMangaParkV3()
    return url:contains('/comic/')
end

local function GetComicId()
    return url:regex('\\/(?:title|comic)\\/(\\d+)', 1)
end

local function GetApiUrl()
    return '/apo/'
end

local function GetApiJson(postDataStr)

    http.Headers['accept'] = '*/*'
    http.Headers['content-type'] = 'application/json'

    return Json.New(http.Post(GetApiUrl(), postDataStr))

end

function GetInfo()

    info.Title = dom.SelectValue('//div[contains(@class,"md:block")]//h3')
    info.Summary = dom.SelectValue('//div[contains(@class,"limit-html-p")]')
    info.AlternativeTitle = dom.SelectValues('//div[contains(@class,"md:block")]//h3/following-sibling::div//span[not(@class)]')
    info.Author = dom.SelectValues('//div[contains(@class,"md:block")]//h3/following-sibling::div[2]//a')
    info.Tags = dom.SelectValues('//b[contains(text(),"Genres:")]/following-sibling::span//span[not(contains(text(),","))]')
    info.Status = dom.SelectValue('//span[contains(text(),"Original Publication")]/following-sibling::span')

end

function GetChapters()

    -- We have to query the API to get the chapter list.

    local comicId = GetComicId()

    local payload = '{"query":"query get_comicChapterList($comicId: ID!) {\\n    get_comicChapterList(comicId: $comicId){\\n      id\\n      data {\\n        \\n  id comicId\\n\\n  isFinal\\n  \\n  volume\\n  serial\\n\\n  dname\\n  title\\n\\n  urlPath\\n\\n  sfw_result\\n\\n      }\\n      # sser_read\\n      # sser_read_serial\\n    }\\n  }","variables":{"comicId":"' .. comicId .. '"}}'

    local chaptersJson = GetApiJson(payload)

    for chapterNode in chaptersJson.SelectTokens('data.get_comicChapterList[*].data') do

        local chapterInfo = ChapterInfo.New()

        chapterInfo.Volume = chapterNode.SelectValue('volume')
        chapterInfo.Title = chapterNode.SelectValue('dname')
        chapterInfo.Url = chapterNode.SelectValue('urlPath')
        chapterInfo.Version = chapterNode.SelectValue('srcTitle')
        chapterInfo.Language = chapterNode.SelectValue('lang')

        chapters.Add(chapterInfo)

    end

end

function GetPages()

    -- Extract image URLs from the JSON at the bottom of the page.

    local imagesScript = dom.SelectValue('//script[contains(@type,"qwik/json")]')

    for imageUrl in imagesScript:regexmany('"(https:\\/\\/[^"]+)"', 1) do

        -- Ignore thumbnail images.

        if(imageUrl:contains('/comic/') or imageUrl:contains('/image/mpup/')) then          
            pages.Add(imageUrl)
        end

    end

end
