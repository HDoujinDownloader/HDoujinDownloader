function Register() -- required

    local module = Module.New()

    module.Name = 'MangaDex'
    module.Domains.Add('mangadex.org')
    module.Domains.Add('mangadex.cc')
    module.Domains.Add('mangadex.com')

    RegisterModule(module)

    global.SetCookie('.' .. module.Domains.First(), "mangadex_h_toggle", "1")

end

function GetInfo() -- required

    local json = GetJsonFromApi(url)    

    if(url:contains('/chapter/')) then

        -- Added from chapter page.

        info.Title = CleanChapterTitle(doc:between('<title>', '</title>'))
        info.Series = info.Title:regex('\\((.+?)\\)$', 1)
        info.Language = json['lang_name']
        info.PageCount = ParsePages(json, PageList.New())

    elseif(url:contains('/manga/') or url:contains('/title/')) then

        -- Added from summary page.
        -- Update (August 27th, 2018): URLs now use "/title/" instead of "/manga/".

        info.Title = json['manga']['title']
        info.AlternativeTitle = doc:between('>Alt name(s):<', '</ul>'):betweenmany('</span>', '</li>')
        info.Author = json['manga']['author']
        info.Artist = json['manga']['artist']
        info.Tags = doc:between('>Genre:<', '</div>'):regexmany("'>([^<]+)", 1)
        info.Status = doc:regex('>(?:Pub\\. status|Status):.+?">([^<]+)', 1)
        info.Summary = json['manga']['description']
        info.Type = json['manga']['lang_name']
        info.Adult = tonumber(json['manga']['hentai']) ~= 0
        info.ChapterCount = ParseChapters(json, ChapterList.New())

    end

end

function GetChapters() -- required
    ParseChapters(GetJsonFromApi(url), chapters)
end

function GetPages() -- required
    ParsePages(GetJsonFromApi(url), pages)
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

function ParseChapters(json, output)
 
    local userLanguages = global.GetSetting('sssMangadexPreferredLanguages'):split(',')
    local acceptAny = userLanguages.Count() <= 0 or userLanguages.Contains(GetLanguageId("all"))

    for chapterJson in json['chapter'] do

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

        chapterInfo.Url = FormatString('/chapter/{0}', chapterJson.Key)
        chapterInfo.Volume = volumeNumber
        chapterInfo.ScanlationGroup = chapterJson['group_name']
        chapterInfo.Language = chapterJson['lang_code']
        
        local uploadTimestamp = tonumber(chapterJson['timestamp'])

        if(uploadTimestamp <= os.time() and (acceptAny or userLanguages.Contains(GetLanguageId(chapterInfo.Language)))) then
            output.Add(chapterInfo)
        end
       
    end

    output.Reverse()

    return output.Count()

end

function ParsePages(json, output)

    local server = json['server']
    local hash = json['hash']

    for filename in json['page_array'] do

        if(not isempty(filename)) then

            pageUrl = FormatString('{0}{1}/{2}', server, hash, filename)

            output.Add(PageInfo.New(pageUrl))
            
        end

    end

    return output.Count()

end

function GetApiUrl(url)

    local apiPath = url
        :regex('\\/((?:title|manga|chapter)\\/\\d+)', 1)
        :replace('title/', 'manga/')

    return FormatString('{0}api/{1}/', GetRoot(url), apiPath)

end

function GetJsonFromApi(url)
    return Json.New(HttpGet(GetApiUrl(url)))
end

function CleanChapterTitle(title)

    -- Works for chapter titles from the chapter list as well as titles from chapters added individually.

    title = tostring(title)
        :before(' - Read Online')
        :before(' - MangaDex')

    return title

end
