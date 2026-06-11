-- LectorXD (lectorxd.com) — HDoujin Downloader module
-- Spanish manhwa/manga/manhua reader (Astro SSR site).
-- Series: /manhwa/<slug> , /manga/<slug> or /manhua/<slug> ·  chapter: /<type>/<slug>/leer/<n>
-- Chapters are sequential 1..N: the range is generated from the highest visible number.

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
    -- Extract base path (/<type>/<slug>) and highest chapter number from visible links
    local base = ''
    local maxChapter = 0
    for node in dom.SelectElements('//a[contains(@href, "/leer/")]') do
        local href = tostring(node.SelectValue('@href'))
        if(base == '') then
            base = href:match('(/%w+/[^/]+)/leer/') or ''
        end
        local n = tonumber(href:match('/leer/(%d+)'))
        if(n ~= nil and n > maxChapter) then
            maxChapter = n
        end
    end
    -- Generate ALL chapters 1..maxChapter (ascending order)
    for i = 1, maxChapter do
        chapters.Add(base..'/leer/'..i, 'Capítulo '..i)
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