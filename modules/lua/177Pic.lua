function Register()

    module.Name = '177漫畫'
    module.Adult = true

    module.Domains.Add('177pic.info', '177漫畫')

end

local function CleanTitle(title)

    return RegexReplace(title, '^\\[(.+?)\\]|(?:\\[DL.\\])?(?:\\[\\d+P\\])?$', '')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Artist = info.Title:regex('^\\[(.+?)\\]', 1)
    info.Tags = dom.SelectValues('//div[contains(@class,"entry-content")]//a[contains(@rel,"tag")]')
    info.PageCount = 0

    if(tostring(info.Tags):contains('Japanese')) then
        info.Language = 'Japanese'
    elseif(tostring(info.Tags):contains('Chinese')) then
        info.Language = 'Chinese'
    elseif(tostring(info.Tags):contains('CG')) then
        info.Type = 'Game CG'
    end

    info.Title = CleanTitle(info.Title)

    -- Make sure we're on the first pagination page.

    info.Url = RegexReplace(info.Url, '\\/\\d+\\/$', '')

end

function GetPages()

    for page in Paginator.New(http, dom, '//a[span/i[contains(@class,"arrowright")]]/@href') do
    
        pages.AddRange(page.SelectValues('//p/img/@data-lazy-src'))
    
    end

end
