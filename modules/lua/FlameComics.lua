function Register()

    module.Name = 'Flame Comics'
    module.Language = 'English'
    module.Adult = false

    module.Domains.Add('flamecomics.com', 'Flame Comics')
    module.Domains.Add('flamecomics.me', 'Flame Comics')
    module.Domains.Add('flamecomics.xyz', 'Flame Comics')
    module.Domains.Add('flamescans.org', 'Flame Comics')

end

local function GetNextDataJson()

    return Json.New(dom.SelectValue('//script[@id="__NEXT_DATA__"]'))

end

function GetInfo()

    local json = GetNextDataJson()

    -- SEARCH DOM DATA

    -- info.Title = dom.SelectValue('//h1')
    -- info.Summary = dom.SelectValue('//h3[contains(text(),"Description")]/following-sibling::div[2]/p')
    -- info.Author = dom.SelectValue('//p[contains(text(),"Author")]/following-sibling::p')
    -- info.Artist = dom.SelectValue('//p[contains(text(),"Artist")]/following-sibling::p')
    -- info.DateReleased = dom.SelectValue('//p[contains(text(),"Release Year")]/following-sibling::p')
    -- info.Type = dom.SelectValue('//p[contains(text(),"Type")]/following-sibling::p')
    -- info.Publisher = dom.SelectValue('//p[contains(text(),"Publisher")]/following-sibling::p')
    -- info.Tags = dom.SelectValues('//h3[contains(text(),"Description")]/following-sibling::div[3]/a/span')
    -- info.Status = dom.SelectValue('//span[contains(text(),"Ongoing") or contains(text(),"Completed") or contains(text(),"Dropped")]')
    -- info.Language = dom.SelectValue('//p[contains(text(),"Language")]/following-sibling::p')

    -- SEARCH JSON DATA

    info.Title = json.SelectValue('props.pageProps.series.title')
    info.AlternativeTitle = json.New(json.SelectValues('props.pageProps.series.altTitles')).SelectValues('[*]')
    info.Summary = json.SelectValue('props.pageProps.series.description')
    info.Author = json.SelectValue('props.pageProps.series.author')
    info.Artist = json.SelectValue('props.pageProps.series.artist')
    info.DateReleased = json.SelectValue('props.pageProps.series.year')
    info.Type = json.SelectValue('props.pageProps.series.type')
    info.Publisher = json.SelectValue('props.pageProps.series.publisher')
    info.Tags = json.New(json.SelectValues('props.pageProps.series.tags')).SelectValues('[*]')
    info.Status = json.SelectValue('props.pageProps.series.status')
    info.Language = json.SelectValue('props.pageProps.series.language')

end

function GetChapters()

    local json = GetNextDataJson()

    local seriesId = json.SelectValue('props.pageProps.series.series_id')

    for chapterJson in json.SelectTokens('props.pageProps.chapters[*]') do

        local chapterNumber = tostring(chapterJson['chapter']):gsub("%.?0+$", "")
        local chapterSubtitle = tostring(chapterJson['title'])
        local chapterToken = tostring(chapterJson['token'])

        local chapter = ChapterInfo.New()

        chapter.Url = '/series/' .. seriesId .. '/' .. chapterToken
        chapter.Title = 'Chapter ' .. chapterNumber .. ' - ' .. chapterSubtitle

        if(isempty(chapterSubtitle)) then
            chapter.Title = 'Chapter ' .. chapterNumber
        end

        chapters.Add(chapter)

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//img[contains(@src, "cdn.flamecomics.xyz/series/")]/@src'))

end