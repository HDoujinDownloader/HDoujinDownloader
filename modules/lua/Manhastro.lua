require "Madara"

function Register()

    module.Name = 'Manhastro'
    module.Language = 'pt-br'

    module.Domains.Add('manhastro.com')

end

function GetPages()

    local imagesScript = dom.SelectValue('//script[contains(text(),"imageLinks")]')
    local imagesLinksStr = imagesScript:regex('imageLinks\\s*=\\s*(\\[.+?\\])',  1)
    local imagesLinksJson = Json.New(imagesLinksStr)

    for encodedImageUrl in imagesLinksJson.SelectValues('[*]') do

        local imageUrl = DecodeBase64(encodedImageUrl)

        pages.Add(imageUrl)

    end

end
