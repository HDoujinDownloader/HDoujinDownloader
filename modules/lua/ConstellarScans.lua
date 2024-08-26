require "WpMangaReader"

local BaseGetInfo = GetInfo
local BaseGetChapters = GetChapters
local BaseGetPages = GetPages

function Register()

    module.Name = 'Constellar Scans'
    module.Language = 'en'
    module.DeferHttpRequests = true

    module.Domains.Add('constellarcomic.com')
    module.Domains.Add('constellarscans.com')

end

local function InitializeDom()

    -- If we try to access galleries without a referer, we'll get infinitely redirected.

   http.AllowAutoRedirect = false
   http.Referer = 'https://' .. module.Domain .. '/'

   dom = Dom.New(http.Get(url))

end

function GetInfo()

    InitializeDom()

    BaseGetInfo()

end

function GetChapters()

    InitializeDom()

    BaseGetChapters()

end

function GetPages()

    InitializeDom()

    BaseGetPages()

end
