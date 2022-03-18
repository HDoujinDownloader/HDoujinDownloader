function Register()

    module.Name = 'MyHentaiGrid'
    module.Adult = true

    module.Domains.Add('myhentaicomics.com', 'My Hentai Comics')
    module.Domains.Add('myhentaigallery.com', 'My Hentai Gallery')
    module.Domains.Add('mymangacomics.com', 'My Manga Comics')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Tags = dom.SelectValues('//div[contains(text(),"Categories:")]/a')
    info.Artist = dom.SelectValues('//div[contains(text(),"Artists:")]/a')
    info.Characters = dom.SelectValues('//div[contains(text(),"Characters:")]/a')
    info.Parody = dom.SelectValues('//div[contains(text(),"Parodies:")]/a')

end

function GetPages()

    for thumbnailUrl in dom.SelectValues('//div[contains(@class,"comic-thumb")]/img/@src') do

        local imageUrl = thumbnailUrl:replace('/thumbnail/', '/original/')

        pages.Add(imageUrl)

    end

end
