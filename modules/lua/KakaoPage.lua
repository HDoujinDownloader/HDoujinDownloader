function Register()

    module.Name = '카카오페이지'
    module.Language = 'ko'
    module.Adult = false
    module.Type = 'webtoon'

    module.Domains.Add('page.kakao.com')

end

local function GetApiUrl()

    return 'https://api2-page.kakao.com/api/'

end

local function GetApiResponse(endpoint)

    http.Headers['accept'] = 'application/json'

    return Json.New(http.Post(GetApiUrl() .. endpoint))

end

local function GetNextDataJson()

    return Json.New(dom.SelectValue('//script[@id="__NEXT_DATA__"]'))

end

function GetInfo()

    local json = GetNextDataJson()

    info.Title = json.SelectValue('props.initialState.series.series.title')
    info.Author = json.SelectValue('props.initialState.series.series.authorName')
    info.Summary = json.SelectValue('props.initialState.series.series.description')

end

function GetChapters()

    local json = GetNextDataJson()

    local seriesId = json.SelectValue('props.initialState.series.series.seriesId')
    local episodeCount = 0
    local currentPage = 0
    local episodesPerPage = 20

    repeat

        http.PostData['seriesid'] = seriesId
        http.PostData['page'] = currentPage
        http.PostData['direction'] = 'asc'
        http.PostData['page_size'] = episodesPerPage
        http.PostData['without_hidden'] = 'true'

        local episodesJson = GetApiResponse('v5/store/singles')
        local episodeNodes = episodesJson.SelectTokens('singles[*]')

        episodeCount = tonumber(episodesJson.SelectValue('total_count'))

        for episodeNode in episodeNodes do

            local chapterId = episodeNode.SelectValue('id')
            local chapterTitle = episodeNode.SelectValue('title')      
            local chapterUrl = 'https://page.kakao.com/viewer?productId=' .. chapterId

            chapters.Add(chapterUrl, chapterTitle)

        end

        currentPage = currentPage + 1

        if(episodeNodes.Count() <= 0) then
            break
        end

    until (chapters.Count() >= episodeCount)

end

function GetPages()

    local json = GetNextDataJson()

    local productId = json.SelectValue('query.productId')

    http.PostData['productId'] = productId
    http.PostData['device_mgr_uid'] = 'Windows - Chrome'
    http.PostData['device_model'] = 'Windows - Chrome'
    http.PostData['deviceId'] = '8e51300d892a7e377dc2009bec6e2c88'

    local episodeJson = GetApiResponse('v1/inven/get_download_data/web')
    local serverUrl = episodeJson.SelectValue('downloadData.members.sAtsServerUrl')

    for pageUrl in episodeJson.SelectValues('downloadData.members.files[*].secureUrl') do
        pages.Add(serverUrl .. pageUrl)
    end 

end
