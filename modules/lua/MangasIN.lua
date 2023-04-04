require "MyMangaReaderCms"

function Register()

    module.Name = 'Mangas.in'
    module.Language = 'Spanish'
    module.Adult = false

    module.Domains.Add('mangas.in')

end

function GetChapters()

    local chaptersScript1 = dom.SelectValue('//script[contains(text(),"newChapterList")]')
    local chaptersArrayName = chaptersScript1:regex('let\\s*fchapter\\s*=\\s*([a-zA-Z0-9]+)', 1)
    local chaptersScript2 = dom.SelectValue('//script[contains(text(),"' .. chaptersArrayName .. '")][1]')
    local chaptersJson = Json.New(chaptersScript2:regex(chaptersArrayName .. '\\s*=\\s*(\\[.+?\\])', 1))
    local mangaSlug = url:regex('\\/manga\\/([^\\/?#]+)', 1)

    for chapterNode in chaptersJson do

        local chapterNumber = chapterNode.SelectValue('number')
        local volumeNumber = chapterNode.SelectValue('volume')
        local chapterSubtitle = chapterNode.SelectValue('name')
        local chapterTitle = '#' .. chapterNumber
        local chapterUrl = '/manga/' .. mangaSlug .. '/' .. chapterNode.SelectValue('slug')

        if(not isempty(chapterSubtitle)) then
            chapterTitle = chapterTitle .. ' - ' .. chapterSubtitle
        end

        chapters.Add(chapterUrl, CleanTitle(chapterTitle))

    end

    chapters.Reverse()

end
