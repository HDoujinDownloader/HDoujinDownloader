function Register()

    module.Name = 'Манга-тян'
    module.Language = 'Russian'

    module.Domains.Add('exhentai-dono.me', 'Хентай-тян!')
    module.Domains.Add('h-chan.me', 'Хентай-тян!')
    module.Domains.Add('manga-chan.me', 'Манга-тян')
    module.Domains.Add('yaoi-chan.me', 'Яой-тян')

end

function GetInfo()

    info.Url = SetDevelopmentAccessParameter(info.Url)

    info.Title = dom.SelectValue('//h1')
    info.AlternativeTitle = dom.SelectValue('//td[contains(text(), "Другие названия")]/following-sibling::td'):split(';')
    info.Type = dom.SelectValue('//td[contains(text(), "Тип")]/following-sibling::td')
    info.Author = dom.SelectValues('//td[contains(text(), "Автор")]/following-sibling::td//a')
    info.Status = dom.SelectValue('//td[contains(text(), "Статус")]/following-sibling::td'):after(',')
    info.Tags = dom.SelectValues('//td[contains(text(), "Тэги")]/following-sibling::td//a')
    info.Translator = dom.SelectValues('//td[contains(text(), "Переводчики")]/following-sibling::td//a')
    info.Summary = dom.SelectValue('//div[@id="description"]/text()[1]')

    -- We might need to get a few fields differently (h-chan.me).

    if(isempty(info.Author)) then
        info.Author = dom.SelectValue('//div[contains(text(), "Автор")]/following-sibling::div')
    end

    if(isempty(info.Tags)) then
        info.Tags = dom.SelectValues('//li[contains(@class, "sidetag")]//a[last()]')
    end

    if(isempty(info.Translator)) then
        info.Translator = dom.SelectValue('//div[contains(text(), "Переводчик")]/following-sibling::div')
    end

    if(isempty(info.Summary)) then
        info.Summary = dom.SelectValue('//div[@id="description"]')
    end

    info.Language = dom.SelectValue('//div[contains(text(), "Язык")]/following-sibling::div')
    info.Parody = dom.SelectValue('//div[contains(text(), "Серия")]/following-sibling::div')

     -- We might not have a title yet if added from the reader.

    if(isempty(info.Title)) then
        info.Title = CleanTitle(dom.Title)
    end

    -- There might not be any chapters listed, and just a "read online" link (h-chan.me).
    -- In that case, just go to the reader.

    if(ParseChapters().Count() <= 0) then

        info.Url = dom.SelectValue('//a[contains(text(), "Читать онлайн")]/@href')
        info.Url = SetDevelopmentAccessParameter(info.Url)

        info.PageCount = ParsePages(info.Url).Count()

    end

end

function GetChapters()

    for chapter in ParseChapters(dom) do
        chapters.Add(chapter)
    end

end

function GetPages()

    url = SetDevelopmentAccessParameter(url)

    pages.AddRange(ParsePages(url))

end

function CleanTitle(title)

    return tostring(title)
        :before('&raquo;')
        :before('читать онлайн')
        :before('онлайн')

end

function Login()

    if(http.Cookies.Empty()) then

        http.Referer = 'https://'..module.Domain..'/index.php'

        http.PostData.Add('login', 'submit')
        http.PostData.Add('login_name', username)
        http.PostData.Add('login_password', password)
        http.PostData.Add('image', 'Вход')
        
        local response = http.PostResponse('https://'..module.Domain..'/index.php')

        if(not response.Cookies.Contains('dle_user_id')) then
            Fail(Error.LoginFailed)
        end

        global.SetCookies(response.Cookies)

    end

end

function ParseChapters()

    local chapterList = ChapterList.New()

    chapterList.AddRange(dom.SelectElements('//table[contains(@class, "table_cha")]//a'))

    chapterList.Reverse()

    return chapterList

end

function ParsePages(url)

    local pageList = PageList.New()

    doc = http.Get(url)

    local pagesJson = Json.New(doc:regex('"fullimg":\\s*(\\[.+?\\])', 1))

    pageList.AddRange(pagesJson)

    return pageList

end

function SetDevelopmentAccessParameter(url)

    if(GetDomain(url) == 'exhentai-dono.me' and isempty(GetParameter(url, 'development_access'))) then

        -- We need to add the "development_access" URI parameter to get the reader to load on this domain.

        url = SetParameter(url, 'development_access', 'true')

        dom = Dom.New(http.Get(url))

    end

    return url

end
