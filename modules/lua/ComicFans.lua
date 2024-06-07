function Register()

    module.Name = 'Comic Fans'
    module.Type = 'Webtoon'

    module.Domains.Add('bilibilicomics.net')
    module.Domains.Add('comicfans.io')

end

local function CleanSummary(summary)

    summary = summary:replace('\\n', '\n')

    return summary

end

function GetInfo()

    info.Title = dom.SelectValue('//div[contains(@class,"book-name")]')
    info.Author = dom.SelectValue('//div[contains(@class,"author-name")]')
    info.Summary = dom.SelectValue('//div[contains(@id,"about-panel")]/div[contains(@class,"content")]'):trim()

    if(isempty(info.Summary)) then
        info.Summary = dom.SelectValue('//meta[@name="description"]/@content')     
    end

    info.Summary = CleanSummary(info.Summary)

end

function GetChapters()

    local bookId = url:regex('\\/comic\\/(\\d+)', 1)
    local pageNumber = 1
    local pageSize = 100
    local totalPages = 0

    repeat

        local endpoint = '//api.comicfans.io/comic-backend/api/v1/content/chapters/page?sortDirection=DESC&bookId=' .. bookId .. '&pageNumber=' .. pageNumber .. '&pageSize=' .. pageSize

        http.Headers['Accept'] = '*/*'
        http.Headers['Origin'] = 'https://' .. module.Domain
        http.Headers['Referer'] = 'https://' .. module.Domain .. '/'
        http.Headers['Site-Domain'] = 'www.comicfans.io'

        local json = Json.New(http.Get(endpoint))

        pageNumber = pageNumber + 1
        totalPages = tonumber(json.SelectValue('data.totalPages'))

        for listNode in json.SelectNodes('data.list[*]') do

            local chapterUrl = '/episode/' .. listNode.SelectValue('id')
            local chapterTitle = '[' .. listNode.SelectValue('chapterOrder') .. '] ' .. listNode.SelectValue('title')

            chapters.Add(chapterUrl, chapterTitle)

        end

    until(pageNumber > totalPages)

    chapters.Reverse()
    
end

function GetPages()

    local jsonStr = dom.SelectValue('//script[contains(@id,"__NUXT_DATA__")]')

    for imageUrl in jsonStr:regexmany('"([^"]+\\.(?:jpe?g|png|gif|webp|avif))"', 1) do

        imageUrl = '//static.comicfans.io/' .. imageUrl

        pages.Add(imageUrl)

    end

end
