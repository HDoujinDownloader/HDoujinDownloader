local function getApiUrl()
    return '/api/'
end

local function getApiJson(endpoint)

    http.Headers['accept'] = 'application/json, text/plain, */*'

    return Json.New(http.Get(getApiUrl() .. endpoint))

end

local function getComidId()
    return dom.SelectValue('//script[contains(text(),"postId")]')
end

function Register()

    module.Name = 'Hive Scans'
    module.Language = 'English'
    module.Adult = false

    module.Domains.Add('hivecomic.com', 'Void Scans')
    module.Domains.Add('hivescans.com', 'Hive Scans')
    module.Domains.Add('hivetoon.com', 'Hive Scans')
    module.Domains.Add('void-scans.com', 'Hive Scans')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1[contains(@itemprop, "name")]')
    info.Summary = dom.SelectValue('//div[contains(@itemprop,"description")]')
    info.Tags = dom.SelectValues('//a[contains(@href, "series?genre")]/span')

end

function GetChapters()

    local seriesId = getComidId():regex('postId\\\\":(\\d+)}', 1)

    if(isempty(seriesId)) then
        return
    end

    local chaptersOffset = 0
    local chaptersPerRequest = 50
    local totalChapters = -1

    repeat

        local endpoint = 'chapters?postId=' .. seriesId .. '&skip=' .. chaptersOffset .. '&take=' .. chaptersPerRequest .. '&order=desc'
        local json = getApiJson(endpoint)

        totalChapters = tonumber(json.SelectValue('totalChapterCount'))

        local chapterNodes = json.SelectTokens('post.chapters[*]')

        if(isempty(chapterNodes)) then
            break
        end

        for chapterJson in chapterNodes do

            if(toboolean(chapterJson.SelectValue('isAccessible'))) then

                local chapterUrl = GetRoot(url) .. 'series/' .. chapterJson.SelectValue('mangaPost.slug') .. '/' .. chapterJson.SelectValue('slug')
                local chapterTitle = 'Chapter ' .. tostring(chapterJson.SelectValue('number'))
                local chapterSubtitle = chapterJson.SelectValue('title')

                if(not isempty(chapterSubtitle)) then
                    chapterTitle = chapterTitle .. ' - ' .. chapterSubtitle
                end

                chapters.Add(chapterUrl, chapterTitle)

            end

        end

        chaptersOffset = chaptersOffset + chaptersPerRequest

    until(chapters.Count() >= totalChapters or chaptersOffset >= totalChapters)

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//img[contains(@src, "/upload/series/")]/@src'))

    if(isempty(pages)) then

        local nextDataScript = dom.SelectValue('//script[contains(text(), "/upload/series/")]')

        pages.AddRange(nextDataScript:regexmany('"url\\\\":\\\\"([^"]+)\\\\"', 1))

    end

end
