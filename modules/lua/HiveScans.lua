function Register()

    module.Name = 'Hive Scans'
    module.Language = 'English'
    module.Adult = false

    module.Domains.Add('hivescans.com', 'Hive Scans')
    module.Domains.Add('hivetoon.com', 'Hive Scans')
    module.Domains.Add('void-scans.com', 'Hive Scans')

end

local function GetApiUrl()

    return '//hivetoon.com/api/'

end

local function GetApiJson(endpoint)

    http.Headers['accept'] = 'application/json, text/plain, */*'

    return Json.New(http.Get(GetApiUrl() .. endpoint))

end

local function GetComicId()

    return dom.SelectValue('//script[contains(text(),"postId")]')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1[contains(@itemprop, "name")]')
    info.Summary = dom.SelectValue('//div[contains(@itemprop,"description")]')
    info.Tags = dom.SelectValues('//a[contains(@href, "series?genre")]/span')

end

function GetChapters()

    local seriesId = GetComicId():regex('postId\\\\":(\\d+)}', 1)

    if(isempty(seriesId)) then
        return
    end

    local chaptersOffset = 0
    local chaptersPerRequest = 50
    local totalChapters = -1

    repeat

        local endpoint = 'chapters?postId=' .. seriesId .. '&skip=' .. chaptersOffset .. '&take=' .. chaptersPerRequest .. '&order=desc'
        local json = GetApiJson(endpoint)

        totalChapters = tonumber(json.SelectValue('totalChapterCount'))

        for chapterJson in json.SelectTokens('post.chapters[*]') do

            if(chapterJson.SelectValue('price') == '0') then

                local chapterUrl = GetRoot(url) .. 'series/' .. chapterJson.SelectValue('mangaPost.slug') .. '/' .. chapterJson.SelectValue('slug')
                local chapterTitle = 'Chapter ' .. tostring(chapterJson.SelectValue('number'))

                chapters.Add(chapterUrl, chapterTitle)

            end

        end

        chaptersOffset = chaptersOffset + chaptersPerRequest

    until (chapters.Count() >= totalChapters)

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//img[contains(@src, "/upload/series/")]/@src'))

    if(isempty(pages)) then

        local nextDataScript = dom.SelectValue('//script[contains(text(), "/upload/series/")]')

        pages.AddRange(nextDataScript:regexmany('"url\\\\":\\\\"([^"]+)\\\\"', 1))

    end

end
