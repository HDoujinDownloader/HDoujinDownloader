function Register()

    module.Name = 'MyAdultComics'
    module.Adult = true

    module.Domains.Add('myadultcomics.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')

end

function GetPages()

    local imagesScript = dom.SelectValue('//script[contains(text(),"template")]')

    pages.AddRange(imagesScript:regexmany('src="([^"]+)', 1))

end
