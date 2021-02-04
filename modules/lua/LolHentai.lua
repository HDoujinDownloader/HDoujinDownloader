function Register()

    module.Name = 'LolHentai'
    module.Adult = true

    module.Domains.Add('lolhentai.net')

end

function GetInfo()

    local heading = dom.SelectValue('//h2')

    info.Title = heading:split('/'):last()
    info.Description = dom.SelectValue('//h4')
    info.Artist = info.Description:regex('drawn by\\s*(.+?)\\s', 1)
    info.Language = heading:regex('\\/\\s*(Chinese|English|Korean)', 1)
    info.PageCount = dom.SelectValue('//span[contains(@class,"count")]'):regex('^\\d+')

    if(isempty(info.PageCount)) then
        info.PageCount = '?'
    end

end

function GetPages()

    local heading = dom.SelectValue('//h2')

    for page in Paginator.New(http, dom, '//a[@rel="next"]/@href') do
    
        local thumbnailUrls = page.SelectValues('//img[contains(@class,"thumbnail")]/@src')

        for i = 0, thumbnailUrls.Count() - 1 do

            local thumbnailUrl = thumbnailUrls[i]
            local fullSizeUrl = RegexReplace(thumbnailUrl, '_data\\/i\\/|-cu_s[^.]+', '')

            pages.Add(fullSizeUrl)

        end

    end

    -- Newer images are listed first for regular image galleries, but comics are in order.

    if(not heading:contains("Comics")) then
        pages.Reverse()
    end

end
