-- This module is a (simpler) duplicate of MyMangaReaderCMS.

function Register()

    module.Name = 'Jpmangas'
    module.Language = 'french'

    module.Domains.Add('jpmangas.cc', 'Jpmangas')
    module.Domains.Add('lelscanvf.cc', 'LelscanVF')
    module.Domains.Add('lelscanvf.com', 'LelscanVF')

end

local function CleanTitle(title)

    return tostring(title):trim():trim(':')

end

function GetInfo()

    info.Title = dom.SelectValue('//h2')
    info.Status = dom.SelectValue('//dt[contains(text(),"Statut")]/following-sibling::dd[1]')
    info.AlternativeTitle = dom.SelectValue('//dt[contains(text(),"Autres noms")]/following-sibling::dd[1]')
    info.Author =  dom.SelectValues('//dt[contains(text(),"Auteur")]/following-sibling::dd[1]//a')
    info.Artist =  dom.SelectValues('//dt[contains(text(),"Artist")]/following-sibling::dd[1]//a')
    info.DateReleased = dom.SelectValue('//dt[contains(text(),"Date de sortie")]/following-sibling::dd[1]')
    info.Tags =  dom.SelectValues('//dt[contains(text(),"Tags")]/following-sibling::dd[1]//a')
    info.Summary = dom.SelectValue('//p')

end

function GetChapters()

    for chapterNode in dom.SelectElements('//h5[contains(@class,"chapter-title")]') do

        local chapterUrl = chapterNode.SelectValue('./a/@href')
        local chapterTitle = CleanTitle(tostring(chapterNode))

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[@id="all"]/img/@data-src'))

end
