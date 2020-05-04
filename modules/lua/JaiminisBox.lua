require "FoolSlide"

function Register()
   
    module.Name = "Jaimini's Box"

    module.Domains.Add("jaiminisbox.com", "Jaimini's Box")
    
end

function GetPages()

    -- The page list used to be a simple base64-encoded string, but a layer of obfuscated has since been added.
    -- The easiest way of dealing with this is to simply evaluate the JavaScript that generates the page list.
    
    local script = dom.SelectValue('//script[contains(text(),"current_page")]')
    local pagesScript = script:regex('var\\s*(?:pages|_0x\\d+)\\s*=\\s*.+?\\n')
    
    local js = JavaScript.New()

    js.Execute(pagesScript)

    local pagesJson = js.GetObject("pages").ToJson()

    pages.AddRange(pagesJson.SelectValues('[*].url'))

end
