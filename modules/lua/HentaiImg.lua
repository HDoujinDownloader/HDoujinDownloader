function Register()

    module.Name = 'Hentai image'
    module.Adult = true
    module.Type = 'Artist CG'

    module.Domains.Add('hentai-img.com', 'Hentai image')

end

function GetInfo()

    info.Title = dom.SelectValue('//h2')
    info.Tags = dom.SelectValues('//p[@id="detail_tag"]//a') 

    -- If the user added a story URL, we need to get the gallery title this way.

    if(isempty(info.Title)) then
        info.Title = dom.SelectValue('//title')
    end
    
    info.Title = CleanTitle(info.Title)

end

function GetPages()

    -- The story viewer lets us access all images in the gallery on one page.

    if(not url:contains('/story/')) then

        url = url:replace('/image/', '/story/')
        dom = Dom.New(http.Get(url))

    end

    pages.AddRange(dom.SelectValues('//amp-img/@src'))

end

function CleanTitle(title)

    return tostring(title)
        :before(' Story Viewer - ')

end
