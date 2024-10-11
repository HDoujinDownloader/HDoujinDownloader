function Register()

    module.Name = 'CG Cosplay'
    module.Type = 'Photography'

    module.Domains.Add('cgcosplay.org')

end

function GetInfo()

    info.Title = dom.SelectValue('//div[contains(@class,"page-title")]')
    info.Tags = dom.SelectValues('//span[contains(@class,"post-info__terms-list")]//a')

end

function GetPages()
    pages.AddRange(dom.SelectValues('//figure[contains(@class,"gallery-item")]//img/@src'))
end
