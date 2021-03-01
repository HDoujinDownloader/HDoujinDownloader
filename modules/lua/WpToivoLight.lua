-- "Toivo Light" is a WordPress theme.
-- https://wordpress.org/themes/toivo-lite/

function Register()

    module.Name = 'Toivo Light'
    module.Language = 'English'

    module.Domains.Add('neverland-manga.com')
    module.Domains.Add('pokemon-manga.com')
    module.Domains.Add('pokemonmanga.com')

end

function GetInfo()

    info.Title = CleanTitle(dom.SelectValue('//h1'))
    info.Summary = dom.SelectValues('//div[contains(@class,"entry-content")]/p'):join('\n')
    info.Tags = dom.SelectValues('//span[contains(@class,"post_tag")]//a')

    module.Name = info.Title

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('(//*[contains(@id, "latest_comics_widget")])[1]//a'))

    chapters.Reverse()

end

function GetPages()

    local totalPages = dom.SelectValue('//span[contains(@class,"_text")]'):after(' of ')

    if(isnumber(totalPages)) then

        -- The reader is paginated.

        for page in Paginator.New(http, dom, '//a[@rel="next"]/@href') do

            local pageUrl = page.SelectValue('//div[@class="entry-content"]//img/@src')

            if(not isempty(pageUrl)) then
                pages.Add(pageUrl)
            end

        end

    else

        -- All pages are listed on the same page.

        pages.AddRange(dom.SelectValues('//div[contains(@class,"entry-content")]//img/@src'))

    end

end

function CleanTitle(title)

    return RegexReplace(tostring(title):trim(), '(?i)\\s*(?:manga online)$', '')

end
