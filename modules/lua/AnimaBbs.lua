-- Anima (amina.co.kr) is a Korean BBS template (?).
-- Most sites use the "Modified-Webtoon bulletin board" theme: http://amina.co.kr/bbs/board.php?bo_table=skin_member&wr_id=7341

function Register()

    module.Name = '아미나'
    module.Type = 'Webtoon'
    module.Language = 'Korean'
    module.Adult = true

    module.Domains.Add('newtoki94.com', '뉴토끼')

end

function GetInfo()

    info.Title = dom.SelectValue('//div[contains(@class,"view-title")]//span')
    info.Summary = dom.SelectValue('//div[contains(@class,"view-title")]//div[contains(@class,"view-content")][2]')

    if(isempty(info.Title)) then -- chapter URLs
        info.Title = dom.SelectValue('//div[contains(@class,"toon-title")]/text()')
    end

end

function GetChapters()
    
    for chapterNode in dom.SelectElements('//ul[contains(@class,"list-body")]//a') do

        local chapterUrl = chapterNode.SelectValue('@href')
        local chapterTitle = chapterNode.SelectValue('span/following-sibling::text()')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    -- There is an "html_encoder" function that is deobfuscated with a call to unescape.
    -- The content of the "html_data" variable is passed to this function, which generates the image list.

    -- Get the html_encoder function.

    local encodedHtmlEncoderJs = tostring(dom):regex("document\\.write\\(unescape\\('(.+?)'\\)", 1)
    local htmlEncoderJs = Dom.New(Unescape(encodedHtmlEncoderJs)).SelectValue('//script')

    htmlEncoderJs = RegexReplace(htmlEncoderJs, '}.+?;', '}return out;')

    local js = JavaScript.New()

    js.Execute(htmlEncoderJs)

    -- Deobfuscate the image URLs.

    local htmlDataJs = tostring(dom):regex("var\\s*html_data.+?html_data\\+='';")   

    js.Execute(htmlDataJs)

    dom = Dom.New(js.Execute('html_encoder(html_data)'))

    -- Get the image URLs.
    -- Note that some galleries have images in the html_data that aren't actually displayed (?). They have a style="display: none" attribute.

    pages.AddRange(dom.SelectValues('//img[not(@style)]/@*[last()]'))

end
