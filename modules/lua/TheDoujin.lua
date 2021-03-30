function Register()

    module.Name = 'TheDoujin'
    module.Adult = true

    module.Domains.Add('thedoujin.com')

    module.Settings.AddCheck('Prefer English titles', false)
        .WithToolTip('If enabled, English titles will be used where available.')

end

function GetInfo()

    if(url:contains('/pages/')) then

        url = url:replace('/pages/', '/categories/'):before('?')
        dom = Dom.New(http.Get(url))

    end

    info.Title = FormatTitle(dom.SelectValue('//div[contains(@class,"breadcrumbs")]/span[last()]'))
    info.Artist = dom.SelectValues('//div[contains(@title,"Artist")]')
    info.Type = dom.SelectValues('//div[contains(@title,"Category")]')
    info.Circle = dom.SelectValues('//div[contains(@title,"Group")]')
    info.Language = dom.SelectValues('//div[contains(@title,"Language")]')
    info.Tags = dom.SelectValues('//div[contains(@title,"Tag")]')

end

function GetPages()

    -- Make sure to include the cover image, which isn't included in the thumbnail gallery.

    pages.AddRange(dom.SelectValues('//img[contains(@src,"/thumbnails/")]/@src'))
    pages.AddRange(dom.SelectValues('//img[contains(@data-src,"/thumbnails/")]/@data-src'))

    for page in pages do

        page.Url = page.Url:replace('//thumbs.', '//www.')
            :replace('/thumbnails/', '/images/')
            :replace('/thumbnail_', '/')

    end

end

function FormatTitle(title)

    local formattedTitle = tostring(title)

    if(toboolean(module.Settings['Prefer English titles'])) then

        local englishTitle = formattedTitle:split(' - ').Last()

        if(not isempty(englishTitle)) then
            formattedTitle = englishTitle
        end

    end

    return formattedTitle

end
