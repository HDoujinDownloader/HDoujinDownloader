function Register()

    module.Name = 'XYZ Comics'
    module.Adult = true

    module.Domains.Add('xyzcomics.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Tags = dom.SelectValues('//p[contains(@class,"entry-tags")]//a')

end

function GetPages()

    local imageData = dom.SelectValue('//script[contains(text(),"initJIG")]')
    
    for imageUrl in imageData:regexmany('"link":("[^"]+")', 1) do
        pages.Add(Json.New(imageUrl))
    end

end
