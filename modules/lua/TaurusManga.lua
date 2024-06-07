-- This site uses a unique Madara variant.

require "IsekaiScan"

function Register()
   
    module.Name = 'TaurusManga'
    module.Language = 'Spanish'

    module.Domains.Add('taurusmanga.com', 'Templo de las Traducciones')
    
end

function GetInfo()

    info.Title = dom.SelectValue('//div[contains(@id,"manga-title")]//div[contains(@id,"title")]')
    info.Status = dom.SelectValue('(//div[contains(@class,"summary-content")])[2]')
    info.Tags = dom.SelectValues('//div[contains(@class,"genres-content")]//a')
    info.Summary = dom.SelectValue('//div[contains(@class,"post-content")]/p')

end

function GetChapters()
    
    chapters.AddRange(dom.SelectElements('//li[contains(@class,"wp-manga-chapter")]/a'))

    chapters.Reverse()

end
