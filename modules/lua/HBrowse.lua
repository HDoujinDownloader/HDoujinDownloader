function Register()

    module.Name = 'HBrowse'
    module.Language = 'en'
    module.Adult = true

    module.Domains.Add('hbrowse.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//td[contains(.,"Title")]/following-sibling::td')
    info.Artist = dom.SelectValues('//td[contains(.,"Artist")]/following-sibling::td//a')
    info.Parody = dom.SelectValues('//td[contains(.,"Origin")]/following-sibling::td//a')
    info.Tags = dom.SelectValues('//h2[@id="categories"]/following-sibling::table//a')

end

function GetChapters()

    for chapterNode in dom.SelectElements('(//h2[@id="chapters"]/following-sibling::table)[1]//tr') do

        local chapterTitle = chapterNode.SelectValue('./td')
        local chapterUrl = chapterNode.SelectValue('.//a/@href')

        chapters.Add(chapterUrl, chapterTitle)

    end

end

function GetPages()

    local initScript = dom.SelectValue('//script[contains(text(),"initializeHBrowse")]')
    local imagesArr = initScript:regex('list\\s*=\\s*(\\[.+?\\])', 1)
    local imageDir  = initScript:regex('imageDir\\s*=\\s*"([^"]+)', 1)

    for filename in Json.New(imagesArr).SelectValues('[*]') do

        if(not isempty(filename) and filename ~= 'zzz') then

            pages.Add(imageDir .. filename)

        end

    end

end
