function Register()

    -- Japanese raws

    module = Module.New()

    module.Name = 'LoveHeaven'

    module.Domains.Add('hanascan.com', 'HanaScan.com')
    module.Domains.Add('kissaway.net', 'KissAway')
    module.Domains.Add('kisslove.net', 'KissLove')
    module.Domains.Add('lhscan.net', 'LoveHeaven')
    module.Domains.Add('lhscans.com', 'LoveHeaven')
    module.Domains.Add('loveheaven.net', 'LoveHeaven')
    module.Domains.Add('mangahato.com', 'MangaHato')
    module.Domains.Add('rawlh.com', 'LoveHeaven')
    
    module.Language = 'Japanese'

    RegisterModule(module)

    -- Translated content

    module = Module.New()

    module.Domains.Add('18lhplus.com', '18LHPlus')
    module.Domains.Add('lhtranslation.net', 'LHTranslation')
    module.Domains.Add('mangabone.com', 'MangaBone')
    module.Domains.Add('manhwa18.*', 'Manhwa18.com') -- manhwa18.net, manhwa18.com
    module.Domains.Add('manhwascan.com', 'Manhwascan') -- not 100% English
    module.Domains.Add('manhwasmut.com', 'ManhwaSmut')

    module.Language = 'English'

    RegisterModule(module)

end

function GetInfo()

    if(url:contains('/read-')) then

        -- Added from chapter page.

        info.Title = CleanTitle(dom.Title)

    elseif(url:contains('/manga-')) then

        -- Added from summary page.
        
        info.Title = dom.SelectValue('//h1')
        info.AlternativeTitle = dom.SelectValue('//li[descendant::i[contains(@class,"fa-clone")]]/text()'):after(':'):trim()
        info.Author = dom.SelectValues('//li[descendant::i[contains(@class,"fa-users")]]//a/text()')
        info.Tags = dom.SelectValues('//li[descendant::i[contains(@class,"fa-tags")]]//a/text()')
        info.Status = dom.SelectValue('//li[descendant::i[contains(@class,"fa-spinner")]]//a/text()')

        -- Sometimes the title is a different element (e.g. kissaway.net).

        if(isempty(info.Title)) then
            info.Title = dom.SelectValue('//h3')
        end

        -- Careful with getting the summary-- It's a little bit different across some sites.
        -- Ex: loveheaven.net vs hanascan.com

        info.Summary = dom.SelectValue('//div[@class="row"]//p[not(@*)]/text()')

        if(isempty(info.Summary)) then -- manhwasmut.com
            info.Summary = dom.SelectValue('//div[contains(@class,"detail")]/div[contains(@class,"content")]')
        end

        if(info.Title:endswith(' - RAW')) then
            info.Language = 'Japanese'
        else

            -- Some modules marked as "English" aren't 100% English (e.g. "WONDER CAT KYUU-CHAN" on manhwascan.com).
            -- Todo: Detect this.

        end

        info.Title = CleanTitle(info.Title):title()

        if(module.Domain:contains('18')) then
            info.Adult = true
        end

        if(module.Domain:contains('manhwa')) then
            info.Type = 'Manhwa'
        end

    end

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//a[@class="chapter" and not(@href="#")]'))

    chapters.Reverse()

end

function GetPages()

    for node in dom.SelectElements('//img[contains(@class,"chapter-img")]') do
        
        local imageUrl = "";

        if(not node.GetAttribute('data-original'):empty()) then
            imageUrl = node.GetAttribute('data-original') -- manhwa18.com, etc.
        elseif(not node.GetAttribute('data-src'):empty()) then
            imageUrl = node.GetAttribute('data-src') -- mangahato.com
        else
            imageUrl = node.GetAttribute('src') -- everything else
        end

        if(not imageUrl:startsWith('http')) then
            imageUrl = DecodeBase64(imageUrl) -- loveheaven.net
        end

        local page = PageInfo.New(imageUrl)

        -- manhwa.club will respond with a 403 error for other referers.

        if(GetDomain(imageUrl) == 'manhwa.club') then
            page.Referer = GetRoot(imageUrl)
        end

        pages.Add(page)

    end

end

function Login()

    if(not http.Cookies.Contains('userName')) then

        local dom = Dom.New(http.Get(url))
        local formAction = dom.SelectValue('//form[@id="signin_form"]/@action')

        http.PostData.Add('email', username)
        http.PostData.Add('password', password)
        http.PostData.Add('isRemember', 1)
        
        local response = http.PostResponse(formAction)

        if(not response.Cookies.Contains('userName')) then
            Fail(Error.LoginFailed)
        end

        global.SetCookies(response.Cookies)

    end

end

function CleanTitle(title)

    return tostring(title)
        :after('You are watching ')
        :beforelast(' Online at ')
        :beforelast(', Read ')
        :beforelast(' - RAW')
        :trim()
        :title()

end
