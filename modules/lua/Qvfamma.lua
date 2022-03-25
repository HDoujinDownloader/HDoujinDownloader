function Register()

    module.Name = 'Qvfamma'
    module.Language = 'Spanish'

    module.Domains.Add('qvfammaonline.blogspot.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1[contains(@class,"entry-title")]')
    info.Author = dom.SelectValue('//i[contains(text(),"autor/arte:")]/span')
    info.Status = dom.SelectValue('//i[contains(.,"Estado (En Japón):")]/span')
    info.Tags = dom.SelectValue('//i[contains(.,"Género:")]/text()'):split(',')

end

function GetChapters()

    -- Get the related posts and consider them chapters.
    -- e.g. /2019/10/fudanshi-shokan-informacion.html

    local title = dom.SelectValue('//h1[contains(@class,"entry-title")]')
    local slug = dom.SelectValue('//a[contains(@href,"/label/")]/@href'):regex('\\/label\\/([^?&]+)', 1)

    -- Summary posts (with the chapters listed below) always have "Información" in the title.
    -- it may appear as "[Información]" or "(Información)" at the end of the title.

    if(title:contains('Información') and not isempty(slug)) then

        local json = Json.New(http.Get('/feeds/posts/default/-/' .. slug .. '?alt=json&max-results=15'))

        for postNode in json.SelectTokens("feed.entry[*].link[?(@.type == 'text/html')]") do

            local postTitle = postNode.SelectValue('title')
            local postUrl = postNode.SelectValue('href')
            
            if(not postTitle:contains('Información')) then
                chapters.Add(postUrl, postTitle)
            end

        end

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class,"entry-content")]//img/@src'))

end
