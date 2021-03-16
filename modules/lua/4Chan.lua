function Register()

    module.Name = '4chan'

    module.Domains.Add('4chan.org')
    module.Domains.Add('4channel.org')
    module.Domains.Add('yuki.la')
    
end

function GetInfo()

    info.Title = dom.SelectValue('//span[contains(@class,"subject")]')
    info.Author = dom.SelectValue('//div[contains(@class,"thread")]//span[@class="name"]')
    info.Summary = dom.SelectValue('//*[contains(@class,"postMessage")]')
    info.Tags = dom.SelectValue('//div[contains(@class,"boardTitle")]')
    info.DateReleased = dom.SelectValue('//span[contains(@class,"dateTime")]/text()[1]')

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

function GetThreadId(url)

    return tostring(url):regex('\\/thread\\/(\\d+)', 1)

end
