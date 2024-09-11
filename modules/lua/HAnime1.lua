-- This site looks very similar to nhentai.net, and in fact directly hotlinks their images.
-- Despite the similar appearance, the underlying HTML is different enough to warrant a separate module.

function Register()

    module.Name = 'Hanime1.me'
    module.Language = 'Chinese'
    module.Adult = true

    module.Domains.Add('hanime1.me')

end

function GetInfo()

    info.Title = dom.SelectValue('//h3[contains(@class,"title")]')
    info.OriginalTitle = dom.SelectValue('//h4[contains(@class,"title")]')
    info.Parody = dom.SelectValues('//h5[contains(text(),"同人")]//a')
    info.Characters = dom.SelectValues('//h5[contains(text(),"角色")]//a')
    info.Tags = dom.SelectValues('//h5[contains(text(),"標籤")]//a')
    info.Author = dom.SelectValues('//h5[contains(text(),"作者")]//a')
    info.Circle = dom.SelectValues('//h5[contains(text(),"社團")]//a')
    info.Language = dom.SelectValues('//h5[contains(text(),"語言")]//a')
    info.Type = dom.SelectValues('//h5[contains(text(),"分類")]//a')

end

function GetPages()

    local thumbnailUrls = dom.SelectValues('//div[contains(@class,"comics-thumbnail-wrapper")]//img/@data-srcset')

    for thumbnailUrl in thumbnailUrls do

        local fullImageUrl = thumbnailUrl

        fullImageUrl = RegexReplace(fullImageUrl, '\\/\\/t\\d?\\.', '//i.')
        fullImageUrl = RegexReplace(fullImageUrl, '(\\d+)t(.+?)$', '$1$2')

        pages.Add(fullImageUrl)

    end

    -- Hanime1.me hotlinks their images directly from nhentai.net.
    -- To avoid getting a 403 error, we need to blank out the referer.

    pages.Referer = ''

end
