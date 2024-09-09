function Register()

    module.Name = 'J18'
    module.Language = 'en'
    module.Type = 'manga'

    module.Domains.Add('doujin.io')

end

local function GetMangaId()
    return url:regex('\\/manga\\/([^\\/]+)', 1)
end

local function GetChapterId()
    return url:regex('\\/chapter\\/([^\\/]+)', 1)
end

function GetApiEndpoint()
    return '/api/'
end

local function SetUpApiHeaders()

    http.Headers['authorization'] = dom.SelectValue('//meta[@name="api-token"]/@content')
    http.Headers['referer'] = url
    http.Headers['csrf-token'] = dom.SelectValue('//meta[@name="csrf-token"]/@content')
    http.Headers['x-requested-with'] = 'XMLHttpRequest'
    http.Headers['x-xsrf-token'] = Unescape(http.Cookies['XSRF-TOKEN'])

end

local function GetApiJson(path)

    SetUpApiHeaders()

    local endpoint = GetApiEndpoint() .. path
    local jsonStr = http.Get(endpoint)

    if(jsonStr:startswith("<")) then
        Fail(Error.LoginRequired)
    end

    local json = Json.New(jsonStr)

    -- Each API request updates cookies.

    if(API_VERSION > 20240825) then
        global.SetCookies(http.Cookies)
    end

    return json

end

function GetInfo()

    local json = GetApiJson('mangas/' .. GetMangaId())

    info.Title = json.SelectValue('data.title')
    info.Summary = json.SelectValue('data.description')
    info.Tags = json.SelectValues('data.tags[*].name')
    info.Author = json.SelectValue('data.creator_name')
    info.Artist = json.SelectValue('data.creator_name')
    info.Publisher = module.Name

end

function GetChapters()

    if(not isempty(GetChapterId())) then
        return
    end

    local mangaId = GetMangaId()
    local json = GetApiJson('chapters?manga_id=' .. mangaId)

    for chapterNode in json.SelectNodes('data[*]') do

        local chapterName = chapterNode.SelectValue('chapter_name')
        local chapterUrl = '/manga/' .. mangaId .. '/chapter/' .. chapterNode.SelectValue('optimus_id')

        chapters.Add(chapterUrl, chapterName)

    end

end

function GetPages()

    local mangaId = GetMangaId()
    local chapterId = GetChapterId()
    local json = GetApiJson('mangas/' .. mangaId .. '/' .. chapterId .. '/manifest')

    for imageNode in json.SelectNodes('readingOrder[*]') do

        if(imageNode.SelectValue('type'):startswith('image')) then
            pages.Add(imageNode.SelectValue('href'))
        end

    end

end

function Login()

    local alreadyLoggedIn = false

    for cookie in http.Cookies do

        if(cookie.Name:startswith('remember_web_')) then
            alreadyLoggedIn = true
        end

    end

    if(not alreadyLoggedIn) then

        local endpoint = 'https://' .. module.Domain .. '/login'

        -- Load the login page to get necessary cookies and tokens.
        
        http.Referer = endpoint

        local dom = Dom.New(http.Get(endpoint))

        local formData = MultipartFormData.New()

        formData.Add('_token', dom.SelectValue('//input[@name="_token"]/@value'))
        formData.Add('email', username)
        formData.Add('password', password)
        formData.Add('remember', 'on')

        http.Headers['content-type'] = 'multipart/form-data; boundary=' .. formData.Boundary
        http.Headers['origin'] = 'https://' .. module.Domain
        
        local response = http.PostResponse(endpoint, formData)
        local success = false

        for cookie in response.Cookies do

            if(cookie.Name:startswith('remember_web_')) then
                success = true
            end

        end

        if(not success) then
            Fail(Error.LoginFailed)
        end

        global.SetCookies(response.Cookies)

    end

end
