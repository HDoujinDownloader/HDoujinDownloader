function Register()

    module.Name = 'Nozomi.la'
    module.Adult = true
    module.Type = 'artist cg'

    module.Domains.Add('nozomi.la')

end

function GetInfo()

    info.Title = GetTag()
    info.Tags = info.Title:split('%20')

end

function GetPages()

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

function BeforeDownloadPage()

    local postId = page.Url:regex('\\/post\\/(\\d+)', 1)
    local fullPath = RegexReplace(postId, '^.*(..)(.)$', '$2/$1/' .. postId)
    local jsonPath = '//j.nozomi.la/post/'.. fullPath .. '.json'

    local json = Json.New(http.Get(jsonPath))

    page.Url = json.SelectValue('imageurl')

end

function GetTag()

    -- If we have multiple tags, we may need to do further processing, but this will work for now.

    local tag = EncodeUriComponent(RegexReplace(GetParameter(url, 'q'), '[\\/]', ''))

    return tag

end

function GetNozomiUrl()

    -- See the implementation here: https://j.nozomi.la/nozomi.js

    local tag = GetTag()

    return '//j.nozomi.la/nozomi/' .. tag .. '.nozomi'

end
