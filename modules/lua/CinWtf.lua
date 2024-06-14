function Register()

    module.Name = 'Cin.wtf'
    module.Adult = true

    module.Domains.Add('cin.ac')
    module.Domains.Add('cin.cin.pw')
    module.Domains.Add('cin.cx')
    module.Domains.Add('cin.guru')
    module.Domains.Add('cin.pw')
    module.Domains.Add('cin.red')
    module.Domains.Add('cin.wtf')

end

local function GetGalleryJson()

    local jsonStr = dom.SelectValue('//script[contains(@id,"__NEXT_DATA__")]')
    
    return Json.New(jsonStr).SelectNode('props.pageProps.data')

end

function GetInfo()

    local json = GetGalleryJson()

    info.Title = json.SelectValue('title.english')
    info.OriginalTitle = json.SelectValue('title.japanese')
    info.Tags = json.SelectValues('tags[*].name')
    info.PageCount = json.SelectValue('num_pages')
    info.Language = json.SelectValue('lang')

end

function GetPages()

    local json = GetGalleryJson()

    pages.AddRange(json.SelectValues('images.pages[*].t'))

    pages.Headers['Accept'] = 'application/json, text/plain, */*'
    pages.Headers['Origin'] = 'https://' .. module.Domain
    pages.Headers['Referer'] = 'https://' .. module.Domain .. '/'

end
