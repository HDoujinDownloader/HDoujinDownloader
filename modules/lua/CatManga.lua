function Register()

    module.Name = 'CatManga'
    module.Adult = false

    module.Domains.Add('catmanga.org')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Tags = dom.SelectValues('//div[contains(@class,"tags")]/p')
    info.Summary = dom.SelectValue('//div[contains(@class,"seriesDesc")]')
    info.Status = dom.SelectValue('//p[contains(@class,"Status")]/text()[last()]')

end

function GetChapters()

    for chapterNode in dom.SelectElements('//a[contains(@class,"chaptertile")]') do

        local chapterUrl = chapterNode.SelectValue('@href')
        local chapterTitle = chapterNode.SelectValue('p[contains(@class, "Title")]')
        local chapterSubtitle = chapterNode.SelectValue('p[contains(@class, "Text")]')

        if(not isempty(chapterSubtitle)) then
            chapterTitle = chapterTitle..' - '..chapterSubtitle
        end

        chapters.Add(chapterUrl, chapterTitle)
 
    end

    chapters.Reverse()

end

function GetPages()

    local json = Json.New(dom.SelectValue('//script[@id="__NEXT_DATA__"]'))

    pages.AddRange(json.SelectValues('props.pageProps.pages[*]'))

end
