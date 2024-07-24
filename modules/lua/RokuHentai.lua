function Register()

    module.Name = 'Roku Hentai'
    module.Adult = true

    module.Domains.Add('rokuhentai.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h3')
    info.Type = dom.SelectValue('//span[contains(@class,"mdc-list-item__text") and contains(text(),"kind:")]'):after("kind:")
    info.Language = dom.SelectValue('//span[contains(@class,"mdc-list-item__text") and contains(text(),"language:")]'):after("language:")
    info.Tags = dom.SelectValue('//span[contains(@class,"mdc-list-item__text") and contains(text(),"tag:")]'):after("tag:")

end

function GetPages()
    pages.AddRange(dom.SelectValues('//img[contains(@class,"site-reader__image")]/@data-src'))
end
