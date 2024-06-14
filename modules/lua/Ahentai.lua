function Register()

    module.Name = 'Ahentai'
    module.Adult = true

    module.Domains.Add('ahentai.top')
    module.Domains.Add('caitlin.top')

end

function GetInfo()

    info.Title = dom.SelectValue('(//h2)[1]')
    info.OriginalTitle = dom.SelectValue('(//h2)[2]')
    info.Language = dom.SelectValues('(//strong[contains(text(),"language")]/following-sibling::div)[1]//span[@class="d"]')
    info.Artist = dom.SelectValues('(//strong[contains(text(),"artist")]/following-sibling::div)[1]//span[@class="d"]')
    info.Circle = dom.SelectValues('(//strong[contains(text(),"group")]/following-sibling::div)[1]//span[@class="d"]')
    info.Parody = dom.SelectValues('(//strong[contains(text(),"parody")]/following-sibling::div)[1]//span[@class="d"]')
    info.Characters = dom.SelectValues('(//strong[contains(text(),"character")]/following-sibling::div)[1]//span[@class="d"]')
    info.Tags = dom.SelectValues('(//strong[contains(text(),"female")]/following-sibling::div)[1]//span[@class="d"]')

    if(isempty(info.Title)) then
        info.Title = dom.SelectValue('//h1')
    end

    -- Adjust the URL so that it's pointed at the reader.

    info.Url = url:replace('/article', '/readOnline')

end

function GetPages()

    local script = dom.SelectValue('//script[contains(text(),"Image_List")]')
    local httpImage = script:regex('HTTP_IMAGE\\s*\\=\\s*\"([^"]+)', 1)
    local httpImage2 = script:regex('HTTP_IMAGE2\\s*\\=\\s*\"([^"]+)', 1)
    local imagesArray = script:regex('Image_List\\s*=\\s*(\\[.+?\\])', 1)
    local imagesJson = Json.New(imagesArray)

    -- The following logic comes from read_online_v2.js.

    for node in imagesJson do

        local sort = tonumber(node['sort'])
        local extension = tostring(node['extension'])

        if(isempty(extension)) then
            extension = 'jpg'
        end

        local imageUrl = httpImage .. tostring(sort) .. '.' .. extension

        if((sort < 21 or sort > 40) and (sort <= 20 or math.fmod(sort, 2) == 1)) then
            imageUrl = httpImage2 .. tostring(sort) .. '.' .. extension
        end

        pages.Add(imageUrl)

    end

end
