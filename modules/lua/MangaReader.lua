function Register()

    module.Name = 'Mangareader'
    module.Language = 'English'
    
    module.Domains.Add('mangareader.net')
 
 end
 
 function GetInfo()
 
     info.Title = dom.SelectValue('//span[@class="name"]')
     info.AlternativeTitle = dom.SelectValue('//td[contains(text(),"Alternate Name")]/following-sibling::td')
     info.DateReleased = dom.SelectValue('//td[contains(text(),"Year of Release")]/following-sibling::td')
     info.Status = dom.SelectValue('//td[contains(text(),"Status")]/following-sibling::td')
     info.Author = dom.SelectValue('//td[contains(text(),"Author")]/following-sibling::td')
     info.Artist = dom.SelectValue('//td[contains(text(),"Artist")]/following-sibling::td')
     info.ReadingDirection = dom.SelectValue('//td[contains(text(),"Reading Direction")]/following-sibling::td')
     info.Tags = dom.SelectValues('//td[contains(text(),"Genre")]/following-sibling::td/a')
     info.Summary = dom.SelectValue('//p')
 
 end
 
 function GetChapters()
 
     local chapterNodes = dom.SelectElements('(//table)[last()]//td[a]')
 
     for chapterNode in chapterNodes do
 
         local chapterInfo = ChapterInfo.New()
 
         chapterInfo.Url = chapterNode.SelectValue('a/@href')
         chapterInfo.Title = tostring(chapterNode):trim(' : ')
 
         chapters.Add(chapterInfo)
 
     end
 
 end
 
 function GetPages()
 
     local json = Json.New(tostring(dom):regex('"im":(\\[.+?])', 1))
 
     pages.AddRange(json.SelectValues('[*].u'))
 
 end
