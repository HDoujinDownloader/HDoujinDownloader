function Register()

    module.Name = 'Nozomi.la'
    module.Adult = true
    module.Type = 'artist cg'

    module.Domains.Add('nozomi.la')

end

function GetInfo()

    if(url:contains('/post/')) then
       
        -- A single post was added.

        local json = GetPostJson(url)

        info.Title = json.SelectValue('postid')
        info.Tags = json.SelectValues('$..tag')
        info.PageCount = 1

    else

        info.Title = GetTag()
        info.Tags = info.Title:split('%20')

    end

end

function GetPages()

    if(url:contains('/post/')) then

        pages.Add(url)

    else

        -- Get the nozomi data, which is uint32s corresponding to each post ID.

        local nozomi = http.GetResponse(GetNozomiUrl(url)).Data
        local total = nozomi.Count() / 4
        
        local galleryIds = List.New()
        
        for i = 0, total - 1 do
            galleryIds.Add(nozomi.GetUInt32(i * 4))
        end
        
        for galleryId in galleryIds do
            pages.Add('//nozomi.la/post/' .. galleryId .. '.html')
        end
        
        -- List older images first.
        
        pages.Reverse()

    end

end

function BeforeDownloadPage()

    local json = GetPostJson(page.Url)

    -- Posts can have multiple image URLs (?), but I haven't seen any like this.

    local isVideo = toboolean(json.SelectValue('is_video'))
    local imageType = json.SelectValue('imageurls[0].type')
    local imageHash = json.SelectValue('imageurls[0].dataid')

    if(isVideo) then

        page.Url = '//v.nozomi.la/' .. FullPathFromHash(imageHash) .. '.' .. imageType
        page.FileExtensionHint = imageType

    else

        page.Url = '//' .. (imageType == 'gif' and 'g' or 'w') .. '.nozomi.la/' .. FullPathFromHash(imageHash) .. '.' .. (imageType == 'gif' and 'gif' or 'webp')

    end

end

function GetTag()

    -- If we have multiple tags, we may need to do further processing, but this will work for now.

    url = url:before('#')

    local tag = EncodeUriComponent(RegexReplace(GetParameter(url, 'q'), '[\\/]', ''))

    return tag

end

function GetNozomiUrl()

    -- Defined in nozomi.js

    local tag = GetTag()

    return '//j.nozomi.la/nozomi/' .. tag .. '.nozomi'

end

function FullPathFromHash(hash)

    -- Defined in main.js

    if(hash:len() < 3) then
        return hash
    end

    return RegexReplace(hash, '^.*(..)(.)$', '$2/$1/' .. hash)

end

function GetPostId(url)

    return url:regex('\\/post\\/(\\d+)', 1)

end

function GetPostJson(url)

    local postId = GetPostId(url)
    local fullPath = RegexReplace(postId, '^.*(..)(.)$', '$2/$1/' .. postId)
    local jsonPath = '//j.nozomi.la/post/'.. fullPath .. '.json'

    return Json.New(http.Get(jsonPath))

end
