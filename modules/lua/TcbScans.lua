function Register()

    module.Name = 'TCB Scans'
    module.Language = 'English'

    module.Domains.Add('onepiecechapters.com')
    module.Domains.Add('tcbscans.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Summary = dom.SelectValue('//h1/following-sibling::p')
    info.Scanlator = 'TCB Scans'

end

function GetChapters()

    for chapterNode in dom.SelectElements('//div[contains(text(),"Chapters")]/following-sibling::a') do

        local chapterUrl = chapterNode.SelectValue('@href')
        local chapterTitle = chapterNode.SelectValue('./div[1]')
        local chapterSubtitle = chapterNode.SelectValue('./div[2]')

        if(not isempty(chapterSubtitle)) then
            chapterTitle = chapterTitle .. ' - ' .. chapterSubtitle
        end

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//picture/img/@src'))

end
