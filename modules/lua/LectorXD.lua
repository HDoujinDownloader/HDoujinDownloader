-- LectorXD (lectorxd.com) — módulo HDoujin Downloader
-- Lector de manhwa en español (Astro SSR; paginación de capítulos en cliente).
-- Serie: /manhwa/<slug>  ·  capítulo: /manhwa/<slug>/leer/<n>
-- Capítulos correlativos 1..N: se genera el rango desde el nº más alto visible.
-- Usa string.match de Lua (no regex .NET) para evitar problemas con :regex en MoonSharp.

function Register()

    module.Name = 'LectorXD'
    module.Language = 'Spanish'
    module.Domains.Add('lectorxd.com', 'LectorXD')

end

function GetInfo()

    info.Title = tostring(dom.SelectValue('//h1'))

    if(info.Title == '') then
        local slug = tostring(url):match('/manhwa/([^/]+)') or ''
        info.Title = (slug:gsub('%-', ' '))
    end

    info.Summary = dom.SelectValue('//div[contains(@class, "description")]')

end

function GetChapters()

    -- 1) slug + capítulo más alto a partir de los enlaces visibles (.../leer/<n>)
    local slug = ''
    local maxChapter = 0

    for node in dom.SelectElements('//a[contains(@href, "/leer/")]') do

        local href = tostring(node.SelectValue('@href'))

        if(slug == '') then
            slug = href:match('/manhwa/([^/]+)/leer') or ''
        end

        local n = tonumber(href:match('/leer/(%d+)'))
        if(n ~= nil and n > maxChapter) then
            maxChapter = n
        end

    end

    if(slug == '') then
        slug = tostring(url):match('/manhwa/([^/]+)') or ''
    end

    -- 2) generar TODOS los capítulos 1..maxChapter (orden ascendente)
    for i = 1, maxChapter do
        chapters.Add('/manhwa/'..slug..'/leer/'..i, 'Capítulo '..i)
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
