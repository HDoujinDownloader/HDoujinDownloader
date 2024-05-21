function Register()

    module.Name = 'AnimeAllSar'
    module.Language = 'spanish'

    module.Domains.Add('animeallstar20.com')
    module.Domains.Add('www.animeallstar20.com')

end

local function CleanTitle(title)

    return RegexReplace(title, '(?i)español$', '')

end

function GetInfo()

    info.Title = CleanTitle(dom.SelectValue('//h3[contains(@class,"post-title")]'))

end

function GetChapters()

    local feedUrl = dom.SelectValue('//ul[@id="listado_epis"]/script/@src'):replace('&amp;', '&')
    local feedScript = http.Get(feedUrl)
    local feedJson = Json.New(feedScript:regex('lista\\((.+}})\\);', 1))

    for node in feedJson.SelectTokens('feed.entry[*].link[*]') do

        local rel = node.SelectValue('rel')

        if(rel == 'alternate') then

            local chapterTitle = CleanTitle(node.SelectValue('title'))
            local chapterUrl = node.SelectValue('href')

            chapters.Add(chapterUrl, chapterTitle)

        end
 
    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"post-body")]//a/img/@src'))

end
