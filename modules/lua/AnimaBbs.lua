-- Anima (amina.co.kr) is a Korean BBS template (?).
-- Most sites use the "Modified-Webtoon bulletin board" theme: http://amina.co.kr/bbs/board.php?bo_table=skin_member&wr_id=7341

function Register()

    module.Name = '아미나'
    module.Type = 'Webtoon'
    module.Language = 'Korean'
    module.Adult = true

    module.Domains.Add('newtoki*.com', '뉴토끼')
    module.Domains.Add('newtoki94.com', '뉴토끼')
    module.Domains.Add('newtoki307.com', '뉴토끼')
    module.Domains.Add('newtoki308.com', '뉴토끼')

end

local function SolveCaptcha()

    -- We need to solve a captcha before we can access the chapter list.

    -- Refresh the DOM in case the CAPTCHA was already solved previously (e.g. in "GetInfo").
    -- Make sure to bypass the response cache.

    dom = Dom.New(http.Get(url .. '#'))

    local hasCaptchaElement = dom.SelectElements('//fieldset[@id="captcha"]').Count() > 0
    
    if(hasCaptchaElement) then

        -- Create a new KCAPTCHA session.

        http.Headers['Accept'] = '*/*'
        http.Headers['X-Requested-With'] = 'XMLHttpRequest'

        http.Post('/plugin/kcaptcha/kcaptcha_session.php')

        -- This URL is generated in "kcaptcha.js".

        local captchaImageUrl = GetRooted(JavaScript.New().Execute('"/plugin/kcaptcha/kcaptcha_image.php?t=" + (new Date).getTime()').ToString(), url)
        local captcha = Captcha.New(http)
        local captchaSolution = captcha.Solve(captchaImageUrl)

        if(not isempty(captchaSolution)) then
            
            local payload = 'url=' .. EncodeUriComponent(url) .. '&captcha_key=' .. captchaSolution

            -- The captcha will redirect to the given URL.

            local response = http.PostResponse('/bbs/captcha_check.php', payload)

            dom = Dom.New(response.Body)

            global.SetCookies(response.Cookies)

        end

    end

end

function GetInfo()

    SolveCaptcha()

    info.Title = dom.SelectValue('//div[contains(@class,"view-title")]//span')
    info.Summary = dom.SelectValue('//div[contains(@class,"view-title")]//div[contains(@class,"view-content")][2]')

    if(isempty(info.Title)) then -- chapter URLs
        info.Title = dom.SelectValue('//div[contains(@class,"toon-title")]/text()')
    end

end

function GetChapters()
   
    SolveCaptcha()

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
