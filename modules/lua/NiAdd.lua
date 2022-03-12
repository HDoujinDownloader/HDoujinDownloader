require 'NineManga'

local BaseGetPages = GetPages

function Register()

    module.Name = 'NiAdd'
    module.Adult = false

    module.Domains.Add('niadd.com')
    module.Domains.Add('nineanime.com')
    module.Domains.Add('www.niadd.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Status = dom.SelectValue('//span[contains(@class,"book-status")]'):between('(', ')')
    info.Author = dom.SelectValues('(//span[contains(text(),"Author(s)")])[1]/following-sibling::a')
    info.Artist = dom.SelectValues('(//span[contains(text(),"Artist")])[1]/following-sibling::a')
    info.Language = dom.SelectValues('(//span[contains(text(),"Language")])[1]/following-sibling::span')
    info.DateReleased = dom.SelectValues('(//span[contains(text(),"Released")])[1]/following-sibling::a')
    info.Tags = dom.SelectValues('(//span[contains(text(),"Genres")])[1]/following-sibling::a')
    info.AlternativeTitle = dom.SelectValue('//span[contains(text(),"Alternative(s)")]/following-sibling::text()')
    info.Summary = dom.SelectValue('//section[contains(@class,"detail-synopsis")]')

end

function GetChapters()

    if(url:contains('/chapter/')) then
        return
    end

    local chaptersListUrl = dom.SelectValue('//a[@title="Chapters"]/@href')

    if(not isempty(chaptersListUrl)) then
        
        url = chaptersListUrl
        dom = Dom.New(http.Get(chaptersListUrl))

    end

    for chapterNode in dom.SelectElements('//ul[contains(@class,"chapter-list")]/a') do

        local chapterTitle = chapterNode.SelectValue('@title')
        local chapterUrl = chapterNode.SelectValue('@href')

        chapters.Add(chapterUrl, chapterTitle)

    end

    chapters.Reverse()
    
end

function GetPages()

    -- Switch to "10 pages" mode, which allows us to access all of the pages.
    -- We will be redirected multiple times.

    url = url:trim('/') .. '-10-1.html'
    dom = Dom.New(http.Get(url))

    BaseGetPages()

end
