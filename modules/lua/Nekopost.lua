function Register()

    module.Name = "Nekopost"
    module.Domain = "nekopost.net"
    module.Language = "Thai"

end

function GetInfo() 

    info.Title = tostring(dom.Title):beforelast(' | ')
    info.Author = dom.SelectValue('//td[contains(text(), "Author")]/following-sibling::td')
    info.Artist = dom.SelectValue('//td[contains(text(), "Author")]/following-sibling::td')
    info.DateReleased = dom.SelectValue('//td[contains(text(), "Release Date")]/following-sibling::td')
    info.Tags = dom.SelectValues('(//div[span[contains(text(), "Category")]])[1]/a')

end

function GetChapters()

    for element in dom.SelectElements('//table[contains(@class, "my-table")]//td') do

        local chapterNumber = element.SelectValue('b')
        local chapterTitle = element.SelectValue('a')
        local chapterUrl = element.SelectValue('a/@href')

        chapters.Add(chapterUrl, chapterNumber .. ' - ' .. chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    doc = http.Get(url)

    local projectJson = GetProjectJson(doc)
    local pageList = GetPagesFromProjectJson(doc, projectJson)

    pages.AddRange(pageList)

end

function GetJsonFolder(projectId)

    local temp = (projectId / 1000) - (mod(projectId, 1000) / 1000)

    if(mod(projectId, 1000) ~= 0) then
        temp = temp + 1
    end

    temp = temp * 1000
    temp = "000000" .. tostring(temp)

    return temp:sub(temp:len() - 5)

end

function GetBaseFileUrl(doc)

    return doc:regex('base_file_url\\s*=\\s*\"(.+?)\"', 1)

end

function GetProjectId(doc)

    return tonumber(doc:regex('projectId\\s*=\\s*\"(\\d+)\"', 1))

end

function GetProjectJson(doc)

    -- Get the JSON file containing the "project" (manga) information.
    -- e.g. www.nekopost.net/file_server/collectJson/<jsonFolder>/<projectId>/<projectId>dtl.json?<runningTime>

    local baseFileUrl = GetBaseFileUrl(doc)
    local projectId = GetProjectId(doc)
    
    local jsonFolder = GetJsonFolder(projectId)
    
    local year = os.date('%Y')
    local month = os.date('%m'):after('0')
    local day = os.date('%d'):after('0')
    local hour = os.date('%I'):after('0')
    local minute = os.date('%M'):after('0')

    local runningTime = year .. month .. day .. hour .. minute

    local jsonPath = baseFileUrl .. 'collectJson/' .. jsonFolder .. '/' .. projectId .. '/' .. projectId .. 'dtl.json?' .. runningTime

    http.Headers['x-requested-with'] = 'XMLHttpRequest'
    http.Headers['accept'] = 'application/json'
    
    return Json.New(http.Get(jsonPath))

end

function GetPagesFromProjectJson(doc, projectJson)

    -- Get the JSON file containing the chapter information. There are two types: "datafile" (df) and "database" (db).
    -- e.g. www.nekopost.net/file_server/collect<type>/<projectId>/<chapterId>/<dataFile>.json
    -- e.g. www.nekopost.net/reader/loadChapterContent/<projectId>/<chapterId>
    
    local baseFileUrl = GetBaseFileUrl(doc)
    local projectId = GetProjectId(doc)

    local projectFolder = 'collect'
    local chapterNo = doc:regex('chapterNo\\s*=\\s*\"(.+?)\"', 1) -- Can be fractional (e.g. "0.1")
    local chapterId = projectJson.SelectValue("chapterList[?(@.nc_chapter_no=='"..chapterNo.."')].nc_chapter_id")
    local npType = projectJson.SelectValue('info.np_type')
    local ncDataFile = projectJson.SelectValue("chapterList[?(@.nc_chapter_no=='"..chapterNo.."')]..nc_data_file")
    local gblChapterType = not isempty(ncDataFile) and "df" or "db"

    if(npType == 'm') then
        projectFolder = projectFolder .. 'Manga'
    elseif(npType == 'n') then
        projectFolder = projectFolder .. 'Novel'
    elseif(npType == 'd') then
        projectFolder = projectFolder .. 'Doujin'
    end

    local chapterPathFolder = baseFileUrl .. projectFolder .. '/' .. projectId .. '/' .. chapterId .. '/'

    local dfTargetUrl = chapterPathFolder .. ncDataFile
    local dbTargetUrl =  'reader/loadChapterContent/' .. projectId .. '/' .. chapterNo
    local targetUrl = (gblChapterType == 'df') and dfTargetUrl or dbTargetUrl

    http.Headers['x-requested-with'] = 'XMLHttpRequest'
    http.Headers['accept'] = 'application/json'

    local chapterJson = Json.New(http.Get(targetUrl))

    -- Convert the image filenames into full image paths here, since we have all the variables to work with.

    projectFolder = baseFileUrl .. projectFolder .. '/' .. projectId .. '/' .. chapterId .. '/'
    
    local filenames = (gblChapterType == 'df') and chapterJson.SelectValues('pageItem[*].fileName') or chapterJson.SelectValues('[*][*].value_url')

    local pageList = List.New()

    for filename in filenames do

        local filePath = projectFolder .. filename

        pageList.Add(filePath)

    end

    return pageList

end

function mod(a, b)

    return a - (math.floor(a / b) * b)

end
