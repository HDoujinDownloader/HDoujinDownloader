function Register()
    module.Name = 'Voyce.Me'
    module.Language = 'English'
    module.Type = 'Webcomic'

    module.Domains.Add('voyce.me')
end

function GetInfo()
    local jsonData = Json.New(dom.SelectValue('//script[@id="__NEXT_DATA__"]'))

    info.Title = jsonData.SelectValue('props.pageProps.series.title')
    info.Author = jsonData.SelectValue('props.pageProps.series.author.username')
    info.Summary = jsonData.SelectValue('props.pageProps.series.description')
    info.Tags = jsonData.SelectValues('props.pageProps.series.genres')
end

function GetChapters()
    local jsonData = Json.New(dom.SelectValue('//script[@id="__NEXT_DATA__"]'))
    local seriesId = jsonData.SelectValue('props.pageProps.series.id')
    local slug = jsonData.SelectValue('props.pageProps.series.slug')
    local cacheBuster = tostring(math.floor(os.time() * 1000)) -- Ensures an integer timestamp
    local apiUrl = 'https://api.voyce.me/app/chapter/id/' .. seriesId .. '?_=cb=' .. cacheBuster .. '&source=web' -- Updated base URL
    
    
    local chaptersJson = Json.New(http.Get(apiUrl))
    for chapterJson in Json.New(chaptersJson.SelectValues('data')).Reverse() do
        if(chapterJson.SelectValue('guest_locked') == "false") then
            local chapterUrl = '/series/' .. slug .. '/' .. chapterJson.SelectValue('id')
            local chapterTitle = chapterJson.SelectValue('title')
            chapters.Add(chapterUrl, chapterTitle)
        end
    end
end

function GetPages()
    local jsonData = Json.New(dom.SelectValue('//script[@id="__NEXT_DATA__"]'))
    local chapterId = jsonData.SelectValue('props.pageProps.chapter.id')
    local graphqlUrl = 'https://graphql.voyce.me/v1/graphql/'
    local graphqlQuery = '{"query":"query ChapterImagesById { voyce_chapter_images(where: {chapter: {id: {_eq: ' .. chapterId .. '}}}, order_by: {sort_order: asc, id: asc} ) { id image chapter_id sort_order } }"}'

    local response = http.Post(graphqlUrl, graphqlQuery, 'application/json')
    local imagesJson = Json.New(response)
    local images = imagesJson.SelectValues('data.voyce_chapter_images[*].image')

    local cdnBase = 'https://dlkfxmdtxtzpb.cloudfront.net/'
    for i = 0, images.Count() -1 do
        images[i] = cdnBase .. images[i]
    end

    pages.AddRange(images)
end

function Login()

end
