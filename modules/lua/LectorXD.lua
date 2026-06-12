-- LectorXD (lectorxd.com) — HDoujin Downloader module
-- Spanish manhwa/manga/manhua reader (Astro SSR site).
-- Series: /manhwa/<slug> , /manga/<slug> or /manhua/<slug> ·  chapter: /<type>/<slug>/leer/<n>
function Register()
    module.Name = 'LectorXD'
    module.Language = 'Spanish'
    module.Domains.Add('lectorxd.com', 'LectorXD')
end
function GetInfo()
    info.Title = tostring(dom.SelectValue('//h1'))
    if(info.Title == '') then
        local slug = tostring(url):match('/([^/]+)$') or ''
        info.Title = (slug:gsub('%-', ' '))
    end
    info.Summary = dom.SelectValue('//div[contains(@class, "description")]')
end
function GetChapters()
    -- Extract base path (/<type>/<slug>) from any visible chapter link
    local base = ''
    local firstHref = tostring(dom.SelectValue('//a[contains(@href, "/leer/")]/@href'))
    if(firstHref ~= '') then
        base = firstHref:match('(/%w+/[^/]+)/leer/') or ''
    end
    -- Parse chapters from embedded chaptersList JS array (supports decimals like 37.5, 80.1)
    local scriptText = tostring(dom.SelectValue('//script[contains(., "chaptersList")]'))
    local seen = {}
    for ch in scriptText:gmatch('"chapter":"([^"]+)"') do
        if(not seen[ch]) then
            seen[ch] = true
            chapters.Add(base..'/leer/'..ch, 'Capítulo '..ch)
        end
    end
end
function GetPages()
    if(collectPages('//*[contains(@class, "page-container")]//img') == 0) then
        collectPages('//img[contains(@class, "page-image")]') -- fallback
    end
end
function collectPages(xpath)
    local count = 0
    for node in dom.SelectElements(xpath) do
        local src = tostring(node.SelectValue('@data-src'))
        if(src == '') then
            src = tostring(node.SelectValue('@src'))
        end
        if(src:sub(1, 4) == 'http') then
            pages.Add(src)
            count = count + 1
        end
    end
    return count
end
