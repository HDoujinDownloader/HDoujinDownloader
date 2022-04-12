function Register()

    module.Name = 'DM5'
    module.Language = 'Chinese'
    
    module.Domains.Add('dm5.com')
    module.Domains.Add('www.dm5.com')

    global.SetCookie('www.dm5.com', "isAdult", "1")

end

function GetInfo()

    info.Title = dom.SelectValue('//div[contains(@class,"info")]/p[span and contains(@class,"title")]/text()')
    info.Author = dom.SelectValues('//p[contains(text(),"作者")]/a')
    info.Status = dom.SelectValue('//span[contains(text(),"状态")]/span')
    info.Tags = dom.SelectValue('//span[contains(text(),"题材")]/a')
    info.Summary = dom.SelectValue('//div[contains(@class,"info")]/p[contains(@class,"content")]')
    info.Adult = info.Tags:contains('限制级')
    
    local pageCount = GetVariableValue('DM5_IMAGE_COUNT')

    if(not isempty(pageCount)) then

        -- Added from chapter page

        info.Title = dom.SelectValues('//div[@class="title"]/span'):join(' - ')
        info.PageCount = pageCount

    end
    
end

function GetChapters()

    -- The chapter list comes in two forms: One for manga (multiple columns), and one for webtoons (single column).
    -- The site won't offer up the chapters unless we provide an Accept-Language header.

    http.Headers['Accept-Language'] = "en-US,en;q=0.5"
    
    dom = dom.New(http.Get(url))

    for chapterNode in dom.SelectElements('//div[@id="chapterlistload"]/ul[1]//li/a') do

        local chapterUrl = chapterNode.SelectValue('@href')
        local chapterTitle = chapterNode.SelectValue('div/p/text()')

        if(isempty(chapterTitle)) then
            chapterTitle = chapterNode.SelectValue('./text()')
        end

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Sort()

end

function GetPages()

    -- The site won't offer up pages unless we provide an Accept-Language header.

    http.Referer = url
    http.Headers['Accept-Language'] = "en-US,en;q=0.5"
    
    dom = dom.New(http.Get(url))

    -- To get the pages, we need to make a GET request to "chapterfun.ashx" with the chapter parameters.
    -- It will respond with Dean Edwards packed JS, which when unpacked reveals the image files.
    -- Each request can yield one or more images, so we need to do this until we get all of them.

    local DM5_IMAGE_COUNT = tonumber(GetVariableValue('DM5_IMAGE_COUNT'))
    local DM5_CID = GetVariableValue('DM5_CID')
    local COMIC_MID = GetVariableValue('COMIC_MID')
    local DM5_VIEWSIGN_DT = GetVariableValue('DM5_VIEWSIGN_DT')
    local DM5_VIEWSIGN = GetVariableValue('DM5_VIEWSIGN')
    
    -- Sometimes we don't get a response when querying for the pages, so make more than one attempt.

    local maxQueryAttempts = 5

    for i = 1, DM5_IMAGE_COUNT do

        local queryUrl = FormatString('/m{0}/chapterfun.ashx?cid={0}&page={1}&key=&language=1&gtk=6&_cid={0}&_mid={2}&_dt={3}&_sign={4}',
            DM5_CID, pages.Count() + 1, COMIC_MID, DM5_VIEWSIGN_DT, DM5_VIEWSIGN)

        for j = 0, maxQueryAttempts - 1 do

            local queryResult = http.Get(queryUrl)

            if(not isempty(queryResult)) then

               -- Execute the packed JS, which gives us a "d" variable, which is an array of image URLs.

                local js = JavaScript.New()

                js.Execute(queryResult)

                local d = js.GetObject("d").ToJson()

                pages.AddRange(d.SelectValues('[*]'))

            end

           if(not isempty(queryResult)) then break end

        end

        if(pages.Count() >= DM5_IMAGE_COUNT) then break end

    end

end

function GetVariableValue(name) 

    return tostring(dom):regex(name..'\\s*=\\s*(.+?)\\s*;', 1):trim('"')

end
