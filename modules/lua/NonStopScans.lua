require 'WpMangaStream'

function Register()

    module.Name = 'Non Stop Scans'
    module.Language = 'English'

    module.Domains.Add('nonstopscans.com')
    module.Domains.Add('www.nonstopscans.com')

end

function GetPages()

    local json = Json.New(dom.SelectValue('//script[contains(text(),"ts_reader.run")]'):regex('ts_reader\\.run\\((.+?)\\);', 1))
    local defaultSource = json.SelectValue('defaultSource')
    local sourceJson = json.SelectToken("$.sources[?(@.source=='" .. defaultSource .. "')]")

    -- If the default source isn't available, just fall back to the default source (this is what the site does).

    if(isempty(sourceJson)) then
        sourceJson = json.SelectToken('$.sources[0]')
    end

    pages.AddRange(sourceJson.SelectValues('images[*]'))

end
