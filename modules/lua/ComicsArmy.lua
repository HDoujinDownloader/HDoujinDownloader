function Register()

    module.Name = 'Comics Army'
    module.Adult = true

    module.Domains.Add('comicsarmy.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Tags = dom.SelectValues('//a[contains(@class,"elementor-post-info__terms-list-item")]')

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"post-content")]//a[img]/@href'))

end
