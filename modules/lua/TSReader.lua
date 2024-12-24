-- Sites using "ts_reader" are typically also using the WpMangaReader/WpMangaStream template.
-- It can be detected by looking for calls to "ts_reader.run".

-- This logic is currently duplicated in "ManhwaFreak.lua" and "NonStopScans.lua".

function GetPages()

    local tsReaderScript = dom.SelectValue('//script[contains(text(),"ts_reader.run")]')

    -- If we can't find the reader script directly, it might be obfuscated (e.g. base64-encoded).

    if(isempty(tsReaderScript)) then

        for base64EncodedScript in dom.SelectValues('//script[contains(@src,"data:text/javascript;base64")]/@src') do

            local decodedScript = DecodeBase64(base64EncodedScript:after('base64,'))

            if(decodedScript:contains('ts_reader.run')) then

                tsReaderScript = decodedScript

                break

            end

        end

    end

    -- Extract the "ts_reader.run" call and convert its arguments to JSON.

    local tsReaderParams = tsReaderScript:regex('ts_reader\\.run\\((.+?)\\)(?:;|\\s*$)')
    local js = JavaScript.New()

    js.Execute('const ts_reader={run:function(n){return JSON.stringify(n)}};')

    local tsReaderJson = Json.New(js.Execute(tsReaderParams))
    local defaultSource = tsReaderJson.SelectValue('defaultSource')
    local sourceJson = tsReaderJson.SelectToken("$.sources[?(@.source=='" .. defaultSource .. "')]")

    -- If the default source isn't available, default to the first source available.

    if(isempty(sourceJson)) then
        sourceJson = tsReaderJson.SelectToken('$.sources[0]')
    end

    pages.AddRange(sourceJson.SelectValues('images[*]'))

end
