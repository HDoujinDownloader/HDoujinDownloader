require "AnyAcgV2"

local BaseGetInfo = GetInfo
local BaseGetChapters = GetChapters
local BaseGetPages = GetPages

function Register()

    module.Name = 'AnyACG'

    module.Domains.Add('bato.to', 'BATO.TO')
    module.Domains.Add('batotoo.com', 'BATO.TO')
    module.Domains.Add('battwo.com', 'Bato.To')
    module.Domains.Add('comiko.net', 'BATO.TO')
    module.Domains.Add('dto.to', 'BATO.TO')
    module.Domains.Add('hto.to', 'BATOTO')
    module.Domains.Add('jto.to', 'BATO.TO')
    module.Domains.Add('mangaseinen.com', 'mangaseinen.com')
    module.Domains.Add('mangatensei.com', 'MangaTensei.com')
    module.Domains.Add('mangatoto.com', 'BATO.TO')
    module.Domains.Add('mto.to', 'BATOTO')
    module.Domains.Add('rawmanga.info', 'raw manga')
    module.Domains.Add('readtoto.org', 'BATOTO')
    module.Domains.Add('wto.to', 'BATO.TO')
    module.Domains.Add('zbato.net', 'BATO.TO')
    module.Domains.Add('zbato.org', 'BATO.TO')

end

function IsAnyAcgV2()

    return url:contains('/series/') or
    url:contains('/chapter/')

end

function GetInfo()

    if(IsAnyAcgV2()) then

        BaseGetInfo()

    else

        local json = Json.New(dom.SelectValue('//astro-island[contains(@props,"originalStatus")]/@props'):replace('&quot;', '\"'))
            .SelectToken('data[1]')

        info.Title = json.SelectValue('name[1]')
        info.AlternativeTitle = Json.New(json.SelectValue('altNames[1]')).SelectValues('[*][1]')
        info.Author = Json.New(json.SelectValue('authors[1]')).SelectValues('[*][1]')
        info.Artist = Json.New(json.SelectValue('artists[1]')).SelectValues('[*][1]')
        info.Tags = Json.New(json.SelectValue('genres[1]')).SelectValues('[*][1]')
        info.Language = json.SelectValue('tranLang[1]')
        info.Status = json.SelectValue('originalStatus[1]')
        info.DateReleased = json.SelectValue('originalPubFrom[1]')
        info.ReadingDirection = json.SelectValue('readDirection[1]')
        info.Summary = json.SelectValue('summary[1].code[-1:]')

    end

end

function GetChapters()

    if(IsAnyAcgV2()) then

        BaseGetChapters()

    else

        chapters.AddRange(dom.SelectElements('//div[contains(@name,"chapter-list")]//a[contains(@href,"/title/")]'))

    end

end

function GetPages()

    if(IsAnyAcgV2()) then

        BaseGetPages()

    else

        local json = Json.New(dom.SelectValue('//astro-island[contains(@props,"imageFiles")]/@props'):replace('&quot;', '\"'))
        local imagesJson = Json.New(json.SelectValue('imageFiles[1]'))

        pages.AddRange(imagesJson.SelectValues('[*][1]'))

    end

end
