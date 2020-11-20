function Register()

    module.Name = 'HentaiNexus'
    module.Language = 'English'
    module.Adult = true

    module.Domains.Add('hentainexus.com')

end

function GetInfo()

    if(url:contains('/read/')) then
       
        -- A reader URL was added.
        -- Redirect to the main gallery page so we can get the metadata.

        url = '/view/'..GetGalleryId(url)
        dom = dom.New(http.Get(url))
        
    end

    info.Title = dom.SelectValue('//h1')
    info.Artist = dom.SelectValue('//td[text()="Artist"]/following-sibling::td')
    info.Language = dom.SelectValue('//td[text()="Language"]/following-sibling::td')
    info.Magazine = dom.SelectValue('//td[text()="Magazine"]/following-sibling::td')
    info.Parody = dom.SelectValue('//td[text()="Parody"]/following-sibling::td')
    info.PageCount = dom.SelectValue('//td[text()="Pages"]/following-sibling::td')
    info.Tags = dom.SelectValues('//td[text()="Tags"]/following-sibling::td//a')
    info.Summary = dom.SelectValue('//td[text()="Description"]/following-sibling::td')

    -- Point the URL to the reader for GetPages.

    info.Url = '/read/'..GetGalleryId(url)

end

function GetPages()

    -- The images are either stored in a plainext or obfsucated image array.
    -- The deobfuscation algorithm is in reader.min.js.

    local initReaderArgument = Json.New(tostring(dom):regex('initReader\\((["[].+?["\\]])', 1))

    if(initReaderArgument.Count() > 0) then

        -- We got an unobfuscated array of images.

        pages.AddRange(initReaderArgument.SelectValues('[*]'))

    else

        -- We got an obfuscated string.

        local js = JavaScript.New()

        -- This is such a stupid workaround, but my atob implementation is broken.
        -- This can be removed after the next update.

        if(isempty(module.Data['atob'])) then

            local atob = http.Get('https://raw.githubusercontent.com/jsdom/abab/master/lib/atob.js')
            atob = atob:regex('(function\\s*atob.+?)module', 1)
            atob = RegexReplace(atob, '\\`\\${data}\\`', 'data')
            
            module.Data['atob'] = atob
            
        end

        js.Execute(module.Data['atob'])
        js.Execute('var obfuscated = "'..tostring(initReaderArgument)..'"')
        js.Execute(DecodeBase64('ZnVuY3Rpb24gZGVvYmZ1c2NhdGUocil7Zm9yKHZhciBlPWF0b2Iociksbz1lLnNsaWNlKDAsNjQpLHQ9ZS5zbGljZSg2NCksYT0iIixjPTA7Yzx0Lmxlbmd0aDspe2Zvcih2YXIgZj10LnNsaWNlKGMsYys2NCksaT0wO2k8NjQ7aSsrKWErPVN0cmluZy5mcm9tQ2hhckNvZGUoZi5jaGFyQ29kZUF0KGkpXm8uY2hhckNvZGVBdChpKSk7Yys9NjQsbz1mfXJldHVybiBhfQ=='))

        local pagesJson = Json.New(js.Execute('deobfuscate(obfuscated)'))

        for f in pagesJson['f'] do
           
            local imageUrl = tostring(pagesJson['b'])..
                tostring(pagesJson['r'])..
                tostring(f['h'])..
                '/'..
                tostring(pagesJson['i'])..
                '/'..
                tostring(f['p'])

            pages.Add(imageUrl)
 
        end

    end

end

function GetGalleryId(url)

    return url:regex('\\/(?:read|view)\\/(\\d+)', 1)

end
