function Register()

    module.Name = 'CatManga'
    module.Adult = false

    module.Domains.Add('catmanga.org')

end

local function GetNextDataJson()

    return Json.New(dom.SelectValue('//script[@id="__NEXT_DATA__"]'))

end

function GetInfo()

    local json = GetNextDataJson()

    info.Title = json.SelectValue('$..series.title')
    info.AlternativeTitle = json.SelectValues('$..alt_titles[*]')
    info.Author = json.SelectValues('$..authors[*]')
    info.Tags = json.SelectValues('$..genres[*]')
    info.Summary = json.SelectValue('$..series.description')
    info.Status = json.SelectValue('$..series.status')

end

function GetChapters()

    local json = GetNextDataJson()

    local seriesId = json.SelectValue('$..series.series_id')

    for chapterNode in json.SelectTokens('$..chapters[*]') do
       
        local chapterNumber = tostring(chapterNode['number'])
        local chapterSubtitle = tostring(chapterNode['title'])

        local chapter = ChapterInfo.New()

        chapter.Url = '/series/' .. seriesId .. '/' .. chapterNumber
        chapter.Title = 'Chapter ' .. chapterNumber
        chapter.Volume = tostring(chapterNode['volume'])

        if(not isempty(chapterSubtitle)) then
            chapter.Title = chapter.Title .. ' - ' .. chapterSubtitle
        end

        chapters.Add(chapter)
        
    end

    -- If we have an individual chapter, the chapters list might be reversed.

    chapters.Sort()
    
end

function GetPages()

    local json = GetNextDataJson()

    pages.AddRange(json.SelectValues('props.pageProps.pages[*]'))

end
