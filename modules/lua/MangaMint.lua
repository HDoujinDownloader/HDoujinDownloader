function Register()

    module.Name = 'MangaMint'
    module.Language = 'English'

    module.Domains.Add('mangasail.co', 'MangaSail')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1'):beforelast('/')

    local authCacheData = tostring(dom):regex('"authcacheP13nAjaxAssemblies":([^}]+?})', 1)
    local authCacheJson = Json.New(authCacheData)

    info.AlternativeTitle = GetFieldFromAuthCache(authCacheJson, 'field-alternate-name'):split(';')
    info.Author = GetFieldFromAuthCache(authCacheJson, 'field-author')
    info.Artist = GetFieldFromAuthCache(authCacheJson, 'field-artist')
    info.Type = GetFieldFromAuthCache(authCacheJson, 'field-type')
    info.Tags = GetFieldFromAuthCache(authCacheJson, 'field-genres')
    info.Summary = GetFieldFromAuthCache(authCacheJson, 'body')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//table[contains(@class,"chlist")]/tbody//a'))

    chapters.Reverse()

end

function GetPages()

    local pagesArray = tostring(dom):regex('"showmanga":{"paths":([^]]+?])', 1)
    local pagesJson = Json.New(pagesArray)

    pages.AddRange(pagesJson.SelectValues('[*]'))

end

function GetFieldFromAuthCache(authCacheJson, field)

    local authCacheUrl = tostring(authCacheJson['span.authcache-p13n-asm-field-node-'..field])

    if(not isempty(authCacheUrl)) then

        http.Referer = url
        http.Headers['accept'] = 'application/json, text/javascript, */*; q=0.01'
        http.Headers['x-requested-with'] = 'XMLHttpRequest'
        http.Headers['x-authcache'] = '1'

        local authCacheJson = Json.New(http.Get(authCacheUrl..'&v=null'))
        local authCacheDom = Dom.New(authCacheJson.SelectValue('field.*'))

        return authCacheDom.DocumentElement.InnerText
            :after(':')
            :replace('&nbsp;', '')

    end

    return ""

end
