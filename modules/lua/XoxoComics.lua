require "NhatTruyen"

local BaseGetInfo = GetInfo
local BaseGetPages = GetPages

function Register()

    module.Name = 'XoxoComics'
    module.Language = 'English'

    module.Domains.Add('xoxocomics.com', 'Xoxocomics')

end

function GetInfo()

    BaseGetInfo()

    info.Author = dom.SelectValue('//p[contains(.,"Author(s)")]/following-sibling::p')
    info.Status = dom.SelectValue('//p[contains(.,"Status")]/following-sibling::p')
    info.Tags = dom.SelectValue('//p[contains(.,"Genres")]/following-sibling::p//a')

end

function GetPages()

    -- Switch to "all pages" mode so we can get all of the images.

    url = url:trim('/') .. '/all'
    dom = Dom.New(http.Get(url))
    
    BaseGetPages()

end
