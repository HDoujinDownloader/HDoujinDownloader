-- Sites using theme will often have "Powered by Genkan" at the bottom right of the page.

function Register()

    module.Name = 'Genkan'
    module.Language = 'English'

    module.Domains.Add('edelgardescans.com', 'Edelgarde Scans')
    module.Domains.Add('hatigarmscanz.net', 'Hatigarm Scans')
    module.Domains.Add('hunlight-scans.info', 'Hunlight Scans')
    module.Domains.Add('kaguyadex.com', 'KaguyaDex')
    module.Domains.Add('methodscans.com', 'Method Scans')
    module.Domains.Add('oneshotscans.com', 'One Shot Scans')
    module.Domains.Add('skscans.com', 'SK Scans')
    module.Domains.Add('the-nonames.com', 'The Nonames Scans')
    module.Domains.Add('wowescans.co', 'Wowe Scans')

end

function GetInfo()

    info.Title = tostring(dom.Title):after(' - ')
    info.Summary = dom.SelectValue('//div[h6[contains(text(), "Description")]]/following-sibling::text()')
    info.Adult = toboolean(dom.SelectValue('//div[div[contains(text(), "Mature (18+)")]]/following-sibling::div'))
    info.Type = dom.SelectValue('//div[div[contains(text(), "Country of Origin")]]/following-sibling::div')
    info.Scanlator = module.GetName(url)    

end

function GetChapters()

    for node in dom.SelectElements('//div[contains(@class, "p-4")]//div[contains(@class, "flex")]') do

        local chapterUrl = node.SelectValue('a/@href')
        local chapterNumber = node.SelectValue('preceding-sibling::span')
        local chapterName = node.SelectValue('a')

        chapters.Add(chapterUrl, 'Chapter '..chapterNumber..' - '..chapterName)

    end

    chapters.Reverse()

end

function GetPages()

    doc = http.Get(url)
    
    local pagesJson = Json.New(doc:regex('chapterPages\\s*=\\s*(\\[.+?\\])', 1))

    pages.AddRange(pagesJson)

end
