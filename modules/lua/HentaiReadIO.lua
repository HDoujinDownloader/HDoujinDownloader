-- This website appears to use a heavy-modified Madara variant (?).
-- The API response format is similar to ManhwaManga.

function Register()

    module.Name = 'Hentairead.io'
    module.Language = 'en'
    module.Adult = true

    module.Domains.Add('hentairead.io')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.AlternativeTitle = dom.SelectValue('//p[contains(.,"Alternative")]/following-sibling::h2')
    info.Author = dom.SelectValue('//p[contains(.,"Author")]/following-sibling::p')
    info.Status = dom.SelectValue('//p[contains(.,"Status")]/following-sibling::p')
    info.Tags = dom.SelectValue('//p[contains(.,"Genres")]/following-sibling::p//a')
    info.Summary = dom.SelectValue('//div[contains(@id,"summary")]')

end

function GetChapters()

    if(url:contains('/chapter-')) then
        return
    end

    local mangaId = url:regex('-(\\d+)(?:\\/|$)', 1)
    local maxChapterPageIndex = 25
    local chapterPageIndex = 1

    while chapterPageIndex < maxChapterPageIndex do

        local apiEndpoint = '/?act=ajax&code=load_list_chapter&manga_id=' .. mangaId .. '&page_num=' .. chapterPageIndex .. '&chap_id=0&keyword='

        http.Headers['referer'] = url
        http.Headers['x-requested-with'] = 'XMLHttpRequest'

        local json = Json.New(http.Get(apiEndpoint))

        dom = Dom.New(json.SelectValue('list_chap'))

        local chapterNodes = dom.SelectElements('//li[contains(@class,"wp-manga-chapter")]//a')

        if(chapterNodes.Count() <= 0) then
            break
        end

        chapters.AddRange(chapterNodes)

        chapterPageIndex = chapterPageIndex + 1

    end

    chapters.Reverse()

end

function GetPages()
    pages.AddRange(dom.SelectValues('//div[contains(@id,"page_")]/img/@src'))
end
