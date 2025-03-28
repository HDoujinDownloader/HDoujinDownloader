require "MangaParkV3"

local V3GetInfo = GetInfo
local V3GetChapters = GetChapters
local V3GetPages = GetPages

require "MangaParkV5"

local V5GetInfo = GetInfo
local V5GetChapters = GetChapters
local V5GetPages = GetPages

function Register()

    module.Name = 'MangaPark'
    module.Language = 'English'

    module.Domains.Add('comicpark.org')
    module.Domains.Add('mangapark.com')
    module.Domains.Add('mangapark.io')
    module.Domains.Add('mangapark.net')
    module.Domains.Add('mangapark.org')

    -- Set the "set" cookie so that 18+ content is visible.

    global.SetCookie('.' .. module.Domains.First(), "set", "h=1")

end

local function IsMangaParkV3()
    return url:contains('/comic/')
end

function GetInfo()

    if(IsMangaParkV3()) then
        V3GetInfo()
    else
        V5GetInfo()
    end

end

function GetChapters()

    if(IsMangaParkV3()) then
        V3GetChapters()
    else
        V5GetChapters()
    end

end

function GetPages()

    if(IsMangaParkV3()) then
        V3GetPages()
    else
        V5GetPages()
    end

end
