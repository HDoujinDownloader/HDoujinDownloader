function Register()

    -- Japanese raws

    module = Module.New()

    module.Name = 'LoveHeaven'

    module.Domains.Add('hanascan.com', 'HanaScan.com')
    module.Domains.Add('kissaway.net', 'KissAway')
    module.Domains.Add('kisslove.net', 'KissLove')
    module.Domains.Add('ksgroupscans.com', 'KSGroupScans')
    module.Domains.Add('lhscan.net', 'LoveHeaven')
    module.Domains.Add('lhscans.com', 'LoveHeaven')
    module.Domains.Add('loveheaven.net', 'LoveHeaven')
    module.Domains.Add('lovehug.net', 'LoveHug')
    module.Domains.Add('mangahato.com', 'MangaHato')
    module.Domains.Add('rawlh.com', 'LoveHeaven')
    
    module.Language = 'Japanese'

    RegisterModule(module)

    -- Translated content

    module = Module.New()

    module.Domains.Add('18lhplus.com', '18LHPlus')
    module.Domains.Add('heroscan.com', 'HeroScan')
    module.Domains.Add('lhtranslation.net', 'LHTranslation')
    module.Domains.Add('mangabone.com', 'MangaBone')
    module.Domains.Add('manhwa18.*', 'Manhwa18.com') -- manhwa18.net, manhwa18.com
    module.Domains.Add('manhwascan.com', 'Manhwascan') -- not 100% English, moved to manhuascan.com
    module.Domains.Add('manhwasmut.com', 'ManhwaSmut')

    module.Language = 'English'

    RegisterModule(module)

end

function GetInfo()

    if(url:contains('/read-') or not isempty(url:regex('\\/\\d+\\/\\d+\\/$'))) then

        -- Added from chapter page.
        -- Update (2021-01-04): lovehug.net uses URLs of the form "lovehug.net/(\d+)/(\d+)".

        info.Title = dom.SelectValues('//div[contains(@class,"chapter-content-top")]//li[position()>2]'):join(' - ')

        if(not info.Title:contains(' - ')) then -- lovehug.net doesn't have enough breadcrumbs, so we only get the last part
            info.Title = CleanTitle(dom.Title)
        end

    elseif(url:contains('/manga-') or not isempty(url:regex('\\/\\d+\\/$'))) then

        -- Added from summary page.
        -- Update (4/1/2021): lovehug.net uses URLs of the form "lovehug.net/(\d+)/".
        
        info.Title = dom.SelectValue('//h1')
        info.AlternativeTitle = dom.SelectValue('//li[descendant::i[contains(@class,"fa-clone")]]/text()'):after(':'):trim()
        info.Author = dom.SelectValues('//li[descendant::i[contains(@class,"fa-users")]]//a/text()')
        info.Tags = dom.SelectValues('//li[descendant::i[contains(@class,"fa-tags")]]//a/text()')
        info.Status = dom.SelectValue('//li[descendant::i[contains(@class,"fa-spinner")]]//a/text()')

        -- Update (1/3/2021): lovehug.net got rid of the title element (h1), so we need to get the title from the breadcrumbs instead.

        if(isempty(info.Title)) then
            info.Title = dom.SelectValue('(//ol//span[@itemprop="name"])[last()]')
        end

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

        if(isempty(info.Summary)) then -- ksgroupscans.com
            info.Summary = dom.SelectValue('//div[contains(@class,"summary-content")]')
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

    -- lovehug.net does not have the class attribute "chapter" on chapter nodes.

    if(isempty(chapters)) then

        for chapterNode in dom.SelectElements('//ul[contains(@class,"list-chapters")]/a') do
            chapters.Add(chapterNode.SelectValue('@href'), chapterNode.SelectValue('@title'))
        end

    end

    chapters.Reverse()

end

function GetPages()

    for node in dom.SelectElements('//img[contains(@class,"chapter-img")]') do
        
        local imageUrl = "";

        if(not node.GetAttribute('data-original'):empty()) then
            imageUrl = node.GetAttribute('data-original') -- manhwa18.com, etc.
        elseif(not node.GetAttribute('data-src'):empty()) then
            imageUrl = node.GetAttribute('data-src') -- mangahato.com
        elseif(not node.GetAttribute('data-pagespeed-lazy-src'):empty()) then
            imageUrl = node.GetAttribute('data-pagespeed-lazy-src') -- lovehug.net
        elseif(not node.GetAttribute('data-aload'):empty()) then
            imageUrl = node.GetAttribute('data-aload') -- lovehug.net (Since Feb. 7th, 2021)
        elseif(not node.GetAttribute('data-srcset'):empty()) then
            imageUrl = node.GetAttribute('data-srcset') -- lovehug.net (Since Feb. 7th, 2021)
        else
            imageUrl = node.GetAttribute('src') -- everything else
        end

        if(not imageUrl:contains('.')) then
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

    -- e.g. "Read MANGA TITLE (MANGA) - RAW"
    -- e.g. "MANGA TITLE (MANGA) - RAW chap 1 latest - WebsiteName - Manga Online"

    title = RegexReplace(title, '(?i)(^(?:Read\\s)|(?:(?:\\(.+?\\))?\\s-\\sRAW|latest\\s-\\s.+?\\s-\\sManga Online)$)', '')

    title = tostring(title)
        :after('You are watching ')
        :beforelast(' Online at ')
        :beforelast(', Read ')
        :trim()
        :title()

    return title

end
