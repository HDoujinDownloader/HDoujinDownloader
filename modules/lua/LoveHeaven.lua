function Register()

    local module = Module.New()

    module.Name = 'LoveHeaven'

    -- Japanese raws

    module.Domains.Add('hanascan.com', 'HanaScan.com')
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

    module.Language = 'English'

    RegisterModule(module)

end

function GetInfo()

    if(url:contains('/read-')) then

        -- Added from chapter page.

        info.Title = CleanTitle(dom.Title)

    elseif(url:contains('/manga-')) then

        -- Added from summary page.

        info.Title = tostring(dom.GetElementsByTagName('h1')[0])
        info.AlternativeTitle = dom.SelectValue('//li[descendant::i[contains(@class,"fa-clone")]]/text()'):after(':'):trim()
        info.Author = dom.SelectValues('//li[descendant::i[contains(@class,"fa-users")]]//a/text()')
        info.Tags = dom.SelectValues('//li[descendant::i[contains(@class,"fa-tags")]]//a/text()')
        info.Status = dom.SelectValue('//li[descendant::i[contains(@class,"fa-spinner")]]//a/text()')

        -- Careful with getting the summary-- It's a little bit different across some sites.
        -- Ex: loveheaven.net vs hanascan.com

        info.Summary = dom.SelectValue('//div[@class="row"]//p[not(@*)]/text()')

        if(info.Title:endswith(' - RAW')) then
            info.Language = 'Japanese'
        else

            -- Some modules marked as "English" aren't 100% English (e.g. "WONDER CAT KYUU-CHAN" on manhwascan.com).
            -- Todo: Detect this.

        end

        info.Title = info.Title:before(' - RAW'):title()

        if(GetDomain(url):contains('18')) then
            info.Adult = true
        end

    end

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//a[@class="chapter"]'))

    chapters.Reverse()

end

function GetPages()

    for node in dom.SelectElements('//img[contains(@class,"chapter-img")]') do
        
        if(not node.GetAttribute('data-original'):empty()) then
            pages.Add(node.GetAttribute('data-original')) -- manhwa18.com, etc.
        elseif(not node.GetAttribute('data-src'):empty()) then
            pages.Add(node.GetAttribute('data-src')) -- mangahato.com
        else
            pages.Add(node.GetAttribute('src')) -- everything else
        end

    end

end

function CleanTitle(title)

    return tostring(title)
        :after('You are watching ')
        :beforelast(' Online at ')
        :beforelast(', Read ')
        :trim()
        :title()

end
