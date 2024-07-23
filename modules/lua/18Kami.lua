function Register()

    module.Name = '18Kami'
    module.Adult = true
    module.Language = 'en'

    module.Domains.Add('18kami.com')

end

local function ParseChapters()

    local chapterList = ChapterList.New()

    for chapterNode in dom.SelectElements('(//div[contains(@class,"episode")])[1]//a') do
        
        local chapterTitle = chapterNode.SelectValue('./li/text()[1]')
        local chapterUrl = chapterNode.SelectValue('./@href')

        chapterList.Add(chapterUrl, chapterTitle)

    end

    return chapterList

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Author = dom.SelectValues('//div[contains(text(),"Author：")]//a')
    info.Tags = dom.SelectValues('//div[contains(text(),"Tags：")]//a')

    if(ParseChapters().Count() <= 0) then
        info.PageCount = dom.SelectValue('//div[contains(text(),"Pages：")]'):regex('\\d+')
    end

    if(isempty(info.Title)) then
        info.Title = dom.SelectValue('//div[contains(@class,"panel-heading")]')
    end

end

function GetChapters()
    chapters.AddRange(ParseChapters())
end

function GetPages()

    local readerUrl = dom.SelectValue('//a[contains(text(),"Start reading")]/@href')

    if(not isempty(readerUrl)) then

        url = readerUrl
        dom = Dom.New(http.Get(url))

    end

    pages.AddRange(dom.SelectValues('//img[@data-page]/@data-original'))

end
