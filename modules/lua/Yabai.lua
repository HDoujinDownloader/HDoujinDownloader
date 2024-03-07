function Register()

    module.Name = 'Yabai!'
    module.Adult = true

    module.Domains.Add('yabai.si')

end

function GetInfo()

    local json = GetGalleryJson()

    info.Title = json.SelectValue('$..data.name')
    info.OriginalTitle = json.SelectValue('$..data.alt_name')
    info.Type = json.SelectValue('$..data.category.name')
    info.Language = json.SelectValues('$..data.tags.Language[*].name')
    info.Artist = json.SelectValues('$..data.tags.Artist[*].name')
    info.Tags = json.SelectValues('$..full_name')
    info.PageCount = json.SelectValue('$..data.page_count')

end

function GetPages()

    -- Navigate to the reader.

    url = RegexReplace(url, '\\/?(?:read)?$', '/read')
    dom = Dom.New(http.Get(url))

    local json = GetGalleryJson()

    local dataNode = json.SelectNode('$..pages.data')
    local pageCount = tonumber(dataNode.SelectValue('count'))
    local root = dataNode.SelectValue('list.root')
    local code = dataNode.SelectValue('list.code')
    local headNode = dataNode.SelectNode('list.head')
    local hashNode = dataNode.SelectNode('list.hash')
    local randNode = dataNode.SelectNode('list.rand')
    local typeNode = dataNode.SelectNode('list.type')

    -- The page order is randomized-- We need to sort it by the "head" value.

    local pagesDict = Dict.New()

    for i = 0, pageCount - 1 do

        -- The "head" value is padded to 4 digits.

        local head = tostring(headNode[i])

        while(head:len() < 4) do
            head = '0' .. head
        end
        
        local pageUrl = root .. '/' .. code .. '/' .. head .. '-' .. tostring(hashNode[i]) .. '-' .. tostring(randNode[i]) .. '.' .. tostring(typeNode[i])

        pagesDict[tonumber(head)] = pageUrl

    end

    for i = 1, pageCount do
        pages.Add(pagesDict[i])
    end

end

function GetGalleryJson()

    return Json.New(dom.SelectValue('//div/@data-page'))

end
