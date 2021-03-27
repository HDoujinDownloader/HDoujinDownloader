function Register()

    module.Name = 'ComicK'

    module.Domains.Add('comick.fun')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.AlternativeTitle = dom.SelectValue('//h1/following-sibling::div'):split(',')
    info.Type = dom.SelectValue('//span[contains(text(),"Origination")]/following-sibling::span')
    info.Tags = dom.SelectValues('//span[contains(text(),"Genres")]/following-sibling::span/a')
    info.Artist = dom.SelectValues('//span[contains(text(),"Artists")]/following-sibling::span/a')
    info.Author = dom.SelectValues('//span[contains(text(),"Authors")]/following-sibling::span/a')
    info.DateReleased = dom.SelectValues('//span[contains(text(),"Published")]/following-sibling::span')
    info.Status = dom.SelectValue('//span[contains(text(),"Status")]/following-sibling::span'):after('📖')
    info.Summary = dom.SelectValue('//div[contains(@class,"comic-desc")]/text()[1]')

    local pageCount = GetImageUrls().Count()

    if(pageCount > 0) then
        info.PageCount = pageCount
    end

end

function GetChapters()

    local baseUrl = url:before('?'):trim('/')..'/'
    local comicId = tostring(dom):regex('{"id":(\\d+)', 1)
    local apiEndpoint = '/api/get_chapters?comicid='..comicId..'&page='
    local currentPage = 1
    local totalChapters = 0

    repeat

        local json = Json.New(http.Get(apiEndpoint..currentPage))
        local chapterNodes = json.SelectTokens('data.chapters[*]')

        for chapterNode in chapterNodes do

            local id = chapterNode.SelectValue('id')
            local number = chapterNode.SelectValue('chap')
            local title = chapterNode.SelectValue('title')
            local volume = chapterNode.SelectValue('vol')
            local language = chapterNode.SelectValue('langName')
            local iso6391 = chapterNode.SelectValue('iso639_1')
            local groups = chapterNode.SelectValues('md_groups[*].title').Join(', ')

            local chapter = ChapterInfo.New()

            chapter.Url = baseUrl..id..'-chapter-'..number..'-'..iso6391
            chapter.Translator = groups
            chapter.Language = language

            if(not isempty(number) and number ~= 'null') then
                chapter.Title = chapter.Title..' Ch. '..number
            end

            if(not isempty(volume) and volume ~= 'null') then
                chapter.Title = chapter.Title..' Vol. '..volume
            end

            if(not isempty(title) and title ~= 'null') then
                chapter.Title = chapter.Title..' '..title
            end

            chapters.Add(chapter)

        end

        if(chapterNodes.Count() <= 0) then
            break
        end

        if(totalChapters <= 0) then
            totalChapters = tonumber(json.SelectValue('data.total'))
        end

        currentPage = currentPage + 1

    until(chapters.Count() >= totalChapters)

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(GetImageUrls())

    -- googleusercontent URLs will 403 with a referer.

    pages.Referer = ''

end

function GetImageUrls()

    local pages = List.New()

    for srcset in dom.SelectValues('//div[contains(@class,"images-reader")]//picture/img/@srcset') do

        local pageUrl = srcset:split(',').Last():trim():split(' ').First()

        pages.Add(pageUrl)

    end

    return pages

end
