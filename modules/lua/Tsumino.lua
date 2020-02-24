function Register() -- required

    local module = Module.New()
    module.Name = 'Tsumino'
    module.Domains.Add('tsumino.com')
    module.Language = "en"
    module.Adult = true

    module.Settings.AddCheck('Add collection entries separately', false)
        .WithToolTip('Instead of treating entries in a collection as chapters of a single task, they will be added to the download queue as individual tasks. This allows the preservation of metadata for all entries.')

    RegisterModule(module)

end

function GetInfo() -- required

    -- Check if we got a captcha (reCAPTCHA) or need to log in.

    if(DetectLoginRequired(doc)) then
        Fail(Error.LoginRequired)
    end

    if(DetectCaptcha(doc)) then

        local error = Error.New(Error.CaptchaRequired)
        error.HelpLink = 'https://doujindownloader.com/faq-how-do-i-download-from-tsumino/'

        Fail(error)

    end

    if(IsReaderPageUrl(url)) then
       
        -- Added from reader page.

        info.Title = doc:between('<title>', '</title>'):after('Tsumino | Read'):before('/'):trim()
        info.PageCount = ParsePageCount(doc)

    elseif(IsSummaryPageUrl(url)) then

        -- Added from summary page.
        -- Ex: https://www.tsumino.com/entry/48598
   
        -- Titles are of the form "translated / original"
        local title = doc:between('<div class="book-title">', '</div>')
        local collection = ParseBookData(doc, 'Collection')

        info.Title = title:before('/'):trim()
        info.OriginalTitle = title:after('/'):trim()
        info.Tags = ParseBookData(doc, 'Tag')
        info.Artist = ParseBookData(doc, 'Artist')
        info.Circle = ParseBookData(doc, 'Group')
        info.Parody = ParseBookData(doc, 'Parody')
        info.Characters = ParseBookData(doc, 'Character')
        info.Type = ParseBookData(doc, 'Category')
        info.Series = collection
        
        if(not isempty(collection) and not url:endswith('#')) then

            -- The gallery is part of a collection (i.e. a multi-part series).
            -- Ex: https://www.tsumino.com/entry/48598
            -- Ex: https://www.tsumino.com/Book/Info/31309/kinjo-yuuwaku-teruhiko-to-okaa-san-hen-kouhen-

            if(toboolean(module.Settings['Add collection entries separately'])) then

                -- Collection items will be added to the queue separately.

                for chapter in ParseChapters(doc, ChapterList.New()) do

                    -- Append a marker we can check for to avoid repeating this process infinitely.     

                    Enqueue(chapter.Url .. '#')

                end

                -- Do not add this URL to the queue (since we added the collection items separately).

                info.Ignore = true

            else

                -- Collection items will be treated like chapters.

                info.Title = collection

            end

        else

            -- The gallery is not part of a collection.

            info.PageCount = ParsePageCount(doc)
            info.Url = info.Url:before('#')

        end
        
    end

end

function GetChapters() -- required
    
    ParseChapters(http.Get(url), chapters)

end

function GetPages() -- required

    ParsePages(http.Get(GetReaderUrlFromUrl(url)), pages)

end

function Login()

    local loginCookieName = '.AspNetCore.Cookies'

    if(not http.Cookies.Contains(loginCookieName)) then
    
        http.Referer = 'https://www.tsumino.com/Account/Login'
    
        http.PostData.Add('username', username)
        http.PostData.Add('password', password)
    
        local response = http.PostResponse('https://www.tsumino.com/Account/Login')
    
        if(not response.Cookies.Contains(loginCookieName)) then
            Fail(Error.LoginFailed)
        end
    
        global.SetCookies(response.Cookies)
    
    end

end

function ParseChapters(doc, chapters)

    for match in RegexMatches(doc:between('collection-table">', 'no-margin">'), '<a href="([^"]+).+?width="100%">([^<]+)') do

        local chapterInfo = ChapterInfo.New()

        chapterInfo.Url = match[1]
        chapterInfo.Title = match[2]

        chapters.Add(chapterInfo)

   end

   return chapters

end

function ParsePages(doc, pages)

    local pageCount = ParsePageCount(doc)
    local pageFormat = doc:regex('data-cdn="([^"]+)', 1)

    for i = 1, tonumber(pageCount) do

        pages.Add(pageFormat:replace('[PAGE]', i))

    end

    return pages

end

function DetectLoginRequired(doc)

    local pageTitle = doc:between('<title>', '</title>')

    return pageTitle:contains(': Login') or pageTitle:contains('Issue Occured (404)')

end

function DetectCaptcha(doc)

    return doc:contains(': Auth</title>')

end

function IsReaderPageUrl(url)

    return url:contains('/Read/')

end

function IsSummaryPageUrl(url)

    return url:contains('/entry/') or url:contains('/Book/')

end

function ParsePageCount(doc)

    local pageCount = doc:regex('(?:> of |data-pages=")(\\d+)', 1)

    if(isnumber(pageCount)) then
        return tonumber(pageCount)
    else
        return 0
    end

end

function ParseBookData(doc, id)

    return doc:regexmany('"book-data" id="' .. EscapeRegexString(id) .. '">.+?>([^<]+)', 1)

end

function GetGalleryIdFromUrl(url)

    return url:regex('\\/(\\d+)(?:$|#|\\?)', 1)

end

function GetReaderUrlFromUrl(url)

    return FormatString("{0}Read/Index/{1}?page=1", GetRoot(url), GetGalleryIdFromUrl(url))

end
