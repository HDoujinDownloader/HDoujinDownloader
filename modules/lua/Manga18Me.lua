function Register()
	module.Name = "Manga18.ME"
	module.Adult = true

	module.Domains:Add("manga18.me")
end

function GetInfo()
	info.Title = dom:SelectValue("//h1")
	info.DateReleased = dom:SelectValue('//div[contains(h5/text(),"Release")]//following-sibling::div')
	info.Status = dom:SelectValue('//div[contains(h5/text(),"Status")]//following-sibling::div')
	info.AlternativeTitle = dom:SelectValue('//div[contains(h5/text(),"Alternative")]//following-sibling::div')
	info.Author = dom:SelectValue('//div[contains(h5/text(),"Author(s)")]//following-sibling::div//a')
	info.Artist = dom:SelectValue('//div[contains(h5/text(),"Artist(s)")]//following-sibling::div//a')
	info.Genres = dom:SelectValue('//div[contains(h5/text(),"Genre(s)")]//following-sibling::div//a')
	info.Type = dom:SelectValue('//div[contains(h5/text(),"Type")]//following-sibling::div')
	info.Summary = dom:SelectValue('//div[contains(@class,"ss-manga")]')
end

function GetChapters()
	chapters:AddRange(dom:SelectNodes('//a[contains(@class,"chapter-name")]'))
	chapters:Reverse()
end

function GetPages()
	pages:AddRange(dom:SelectValues('//div[contains(@class,"read-content")]//img/@data-src'))
end
