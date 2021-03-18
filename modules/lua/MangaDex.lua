function Register()

    module.Name = 'MangaDex'

    module.Domains.Add('mangadex.org')
    module.Domains.Add('mangadex.cc')
    module.Domains.Add('mangadex.com')

    global.SetCookie(module.Domains.First(), 'mangadex_h_toggle', '1')

end

function GetInfo()

    local apiEndpoint = GetMangaOrChapterApiEndpoint(url)
    local json = Json.New(http.Get(apiEndpoint))

    if(url:contains('/chapter/')) then

        -- Added from chapter page.

        info.Title = CleanChapterTitle(dom.Title)
        info.Series = json.SelectValue('data.mangaTitle')
        info.Language = json.SelectValue('data.language')
        info.PageCount = json.SelectValues('data.pages[*]').Count()

    elseif(url:contains('/manga/') or url:contains('/title/')) then

        -- Added from summary page.
        -- Update (August 27th, 2018): URLs now use "/title/" instead of "/manga/".

        info.Title = json.SelectValue('data.title')
        info.AlternativeTitle = json.SelectValues('data.altTitles[*]')
        info.Author = json.SelectValues('data.author[*]')
        info.Artist = json.SelectValues('data.artist[*]')
        info.Language = json.SelectValue('data.publication.language')
        info.Tags = dom.SelectValues('//a[contains(@href,"/genre")]')
        info.Status = dom.SelectValue('//div[contains(text(),"status:") or contains(text(),"Status:")]/following-sibling::div')
        info.Summary = json.SelectValue('data.description')
        info.Type = json.SelectValue('data.publication.language')
        info.Adult = toboolean(json.SelectValue('data.isHentai'))

    end

end

function GetChapters()

    local apiEndpoint = GetMangaOrChapterApiEndpoint(url)..'chapters'
    local json = Json.New(http.Get(apiEndpoint))

    local sssMangadexPreferredLanguages = global.GetSetting('sssMangadexPreferredLanguages')
    local userLanguages = sssMangadexPreferredLanguages:split(',')
    local acceptAny = isempty(sssMangadexPreferredLanguages) or userLanguages.Count() <= 0 or userLanguages.Contains(GetLanguageId("all"))
    
    for chapterJson in json['data']['chapters'] do
        
        chapterInfo = ChapterInfo.New()
        
        volumeNumber = chapterJson['volume']
        chapterNumber = chapterJson['chapter']
        chapterSubtitle = CleanChapterTitle(chapterJson['title'])
        
        -- Not all chapters have chapter and volume numbers, and not all chapters have titles.
        -- Ex: https://mangadex.org/title/23747/sekkaku-cheat (no volume numbers, no titles)

        if(not isempty(chapterNumber)) then
            chapterInfo.Title = FormatString("Ch. {0}",  chapterNumber)
        end

        if(not isempty(volumeNumber)) then
            chapterInfo.Title = FormatString("Vol. {0} {1}", volumeNumber, chapterInfo.Title):trim()
        end

        if(not isempty(chapterSubtitle:trim())) then

            if(not isempty(chapterInfo.Title)) then
                chapterInfo.Title = chapterInfo.Title .. ' - '
            end

            chapterInfo.Title = chapterInfo.Title .. chapterSubtitle

        end

        chapterInfo.Url = FormatString('/chapter/{0}', chapterJson['id'])
        chapterInfo.Volume = volumeNumber
        chapterInfo.Language = chapterJson['language']

        local groupId = chapterJson.SelectValues('groups[*]').First()

        if(not isempty(groupId)) then
            chapterInfo.ScanlationGroup = json.SelectValue("data.groups[?(@.id == "..groupId..")].name")
        end

        local uploadTimestamp = tonumber(chapterJson['timestamp'])
        
        if(uploadTimestamp <= os.time() and (acceptAny or userLanguages.Contains(GetLanguageId(chapterInfo.Language)))) then
            chapters.Add(chapterInfo)
        end
       
    end

    chapters.Reverse()

end

function GetPages()

    local apiEndpoint = GetMangaOrChapterApiEndpoint(url)
    local json = Json.New(http.Get(apiEndpoint))

    local server = json.SelectValue('data.server')
    local serverFallback = json.SelectValue('data.serverFallback')
    local hash = json.SelectValue('data.hash')

    for filename in json.SelectValues('data.pages[*]') do

        if(not isempty(filename)) then

            local pageInfo = PageInfo.New()

            pageInfo.Url = FormatString('{0}{1}/{2}', server, hash, filename)
            pageInfo.BackupUrls.Add(FormatString('{0}{1}/{2}', serverFallback, hash, filename))
            
            pages.Add(pageInfo)

        end

    end

end

function Login()
    
    if(not http.Cookies.Contains('mangadex_session')) then

        http.Referer = 'https://'..module.Domain..'/login'

        -- Make an initial request to get session cookie(s).

        http.Get(http.Referer)

        -- Build multipart form data.

        local formData = MultipartFormData.New()

        formData.Add('login_username', username)
        formData.Add('login_password', password)
        formData.Add('two_factor', '')
        formData.Add('remember_me', '1')

        -- Make the login request.

        http.Headers['accept'] = '*/*'
        http.Headers['content-type'] = formData.ContentType
        http.Headers['x-requested-with'] = 'XMLHttpRequest'

        local response = http.PostResponse('https://'..module.Domain..'/ajax/actions.ajax.php?function=login', formData)
        
        if(not response.Cookies.Contains('mangadex_session')) then
            Fail(Error.LoginFailed)
        end

        global.SetCookies(response.Cookies)

    end

end

function GetApiEndpoint(url)

    return '//api.'..module.Domain..'/v2/'

end

function GetMangaOrChapterApiEndpoint(url)

    local path = url
        :regex('\\/((?:title|manga|chapter)\\/\\d+)', 1)
        :replace('title/', 'manga/')

    return GetApiEndpoint(url)..path..'/'

end

function CleanChapterTitle(title)

    -- Works for chapter titles from the chapter list as well as titles from chapters added individually.

    title = tostring(title)
        :before(' - Read Online')
        :before(' - MangaDex')

    return title

end
