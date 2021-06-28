require 'nhentai'

local BaseGetPages = GetPages

function Register()

    module.Name = 'NyaHentai.com'
    module.Language = 'English'
    module.Adult = true

    module.Domains.Add('nyahentai.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Artist = dom.SelectValues('//div[contains(text(),"Artists:")]//a/text()[1]')
    info.Language = dom.SelectValues('//div[contains(text(),"Languages:")]//a/text()[1]')
    info.Type = dom.SelectValues('//div[contains(text(),"Categories:")]//a/text()[1]')
    info.Tags = dom.SelectValues('//div[contains(text(),"Tags:")]//a/text()[1]')

end

function GetPages()

    BaseGetPages()

    -- The full-size images are served from a different domain than the thumbnails.

    for page in pages do

        page.Url = page.Url
            :replace('//t', '//i')
            :replace('.mspcdn.', '.dspcdn.')

    end

end
