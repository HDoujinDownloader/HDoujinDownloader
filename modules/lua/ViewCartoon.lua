function Register()

    module.Name = 'ViewCartoon'
    module.Language = 'thai'

    module.Domains.Add('viewcartoon.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//b')
    info.Summary = dom.SelectValue('//div[b]/following-sibling::text()')
    info.Tags = dom.SelectValue('//b[contains(text(),"tag:")]/following-sibling::text()')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//a[@target="vc"]'))

    chapters.Reverse()

end

function GetPages()

    for page in Paginator.New(http, dom, '//a[contains(text(),"หน้าถัดไป")]/@href') do

        pages.Add(page.SelectValue('//img/@src'))

    end

end
