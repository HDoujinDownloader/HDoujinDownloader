function Register()

    module.Name = 'Pururin'
    module.Language = 'English'
    module.Adult = true

    module.Domains.Add('pururin.io')
    module.Domains.Add('pururin.to')
    module.Domains.Add('pururin.us')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1'):before('/')
    info.OriginalTitle = dom.SelectValue('//h1'):after('/')
    info.AlternativeTitle = dom.SelectValue('//div[contains(@class,"alt-title")]')
    info.Artist = dom.SelectValues('//td[contains(text(),"Artist")]/following-sibling::td//a')
    info.Circle = dom.SelectValues('//td[contains(text(),"Circle")]/following-sibling::td//a')
    info.Parody = dom.SelectValues('//td[contains(text(),"Parody")]/following-sibling::td//a')
    info.Tags = dom.SelectValues('//td[contains(text(),"Contents")]/following-sibling::td//a')
    info.Type = dom.SelectValues('//td[contains(text(),"Category")]/following-sibling::td//a')
    info.Characters = dom.SelectValues('//td[contains(text(),"Character")]/following-sibling::td//a')
    info.Language = dom.SelectValues('//td[contains(text(),"Language")]/following-sibling::td//a')
    info.Scanlator = dom.SelectValues('//td[contains(text(),"Scanlator")]/following-sibling::td//a')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//table[contains(@class,"table-collection")]//a'))

end

function GetPages()

    local galleryId = url:regex('gallery\\/(\\d+)', 1)
    local pageCount = tonumber(dom.SelectValue('//td[contains(text(),"Pages")]/following-sibling::td'):regex('^\\d+'))

    for i = 1, pageCount do

        pages.Add('//cdn.' .. module.Domain .. '/assets/images/data/' .. galleryId .. '/' .. i .. '.jpg')

    end

end
