function Register()

    module.Name = 'Genkan.io'
    module.Adult = false
    module.Language = 'English'

    module.Domains.Add('genkan.io')

end

function GetInfo()

    info.Title = dom.SelectValue('//h2')
    info.Summary = dom.SelectValue('//h2/following-sibling::p')
    info.ChapterCount = dom.SelectValue('//h2[contains(text(),"Chapters")]/following-sibling::ul//div')
    info.Language = dom.SelectValue('//h2[contains(text(),"Available Languages")]/following-sibling::ul//div')
    info.Adult = dom.SelectValue('//h2[contains(text(),"Over 18?")]/following-sibling::ul//div') == 'Yes'

end

function GetChapters()

    for page in Paginator.New(http, dom, '//a[@rel="next"]/@href') do
    
        local chapterNodes = page.SelectElements('//tbody/tr')

        for i = 0, chapterNodes.Count() - 1 do

            local chapterNode = chapterNodes[i]
            local chapterInfo = ChapterInfo.New()
            local chapterName = chapterNode.SelectValue('td[2]'):trim()
    
            chapterInfo.Title = chapterNode.SelectValue('td[1]')
    
            if(not not isempty(chapterName) and chapterName ~= '-') then
                chapterInfo.Title = chapterInfo.Title ..' - '..chapterName
            end
    
            chapterInfo.Language = chapterNode.SelectValue('td[3]')
            chapterInfo.Scanlator = chapterNode.SelectValue('td[4]')
            chapterInfo.Url = chapterNode.SelectValue('td[7]/a/@href')
    
            chapters.Add(chapterInfo)

        end
    
    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"container")]/img/@src'))

end
