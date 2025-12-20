function Register()
	module.Name = "AnyACG (V4)"
end

function GetInfo()
	info.Title = dom:SelectValue("//h3")
	info.Author = dom:SelectValue('//a[contains(@href,"/author?")]')
	info.Summary = dom:SelectValue('//div[contains(@class,"limit-html-p")]')
	info.Tags = dom:SelectValues('//b[contains(text(),"Genres:")]/following-sibling::span')
	info.Status = dom:SelectValue('//span[contains(text(),"Original Publication:")]/following-sibling::span[1]')
	info.ReadingDirection = dom:SelectValue('//span[contains(text(),"Read Direction:")]/following-sibling::span[1]')
end

function GetChapters()
	chapters:AddRange(dom:SelectNodes('//div[contains(@data-name,"chapter-list")]//a[contains(@href,"/title/")]'))
	chapters:Reverse()
end

function GetPages()
	-- Extract all image URLs from the page JSON.
	local json = dom:SelectValue('//script[contains(@type,"qwik/json") and contains(text(),"image_server")]')
	for imageUrl in json:regexmany('"(https:\\/\\/.[^"]+)"', 1) do
		if imageUrl:contains("/media/mbch/") then
			pages:Add(imageUrl)
		end
	end
end
