function Register()

    module.Name = '4chan'
    module.Strict = false

    module.Domains.Add('4chan.org')
    module.Domains.Add('4channel.org')
    module.Domains.Add('boards.4chan.org')
    module.Domains.Add('boards.4channel.org')
    module.Domains.Add('yuki.la')
    
end

local function GetThreadId(url)

    return tostring(url):regex('\\/thread\\/(\\d+)', 1)

end

local function GetMetadataFromJson(jsonStr)

    local json = Json.New(jsonStr)

    info.Title = json.SelectValue('posts[*].sub')
    info.Author = json.SelectValue('posts[*].name')
    info.Summary = json.SelectValue('posts[*].com')
    info.PageCount = json.SelectValues('posts[*].filename').Count()
    info.Tags = '/'..url:between(module.Domain..'/', '/')..'/' -- board

end

function GetInfo()

    if(doc:startswith('{')) then

        GetMetadataFromJson(doc)

    else

        info.Title = dom.SelectValue('//div[contains(@class,"desktop")]//span[contains(@class,"subject")]')
        info.Author = dom.SelectValue('//div[contains(@class,"thread")]//span[@class="name"]')
        info.Summary = dom.SelectValue('//*[contains(@class,"postMessage")]')
        info.Tags = dom.SelectValue('//div[contains(@class,"boardTitle")]')
        info.DateReleased = dom.SelectValue('//span[contains(@class,"dateTime")]/text()[1]')

    end

    if(isempty(info.Title)) then
        info.Title = GetThreadId(url)
    end

    if(module.Domain == '4chan.org') then
        info.Adult = true
    end

end

function GetPages()

    pages.AddRange(dom.SelectValues('//a[contains(@class,"fileThumb")]/@href'))

end
