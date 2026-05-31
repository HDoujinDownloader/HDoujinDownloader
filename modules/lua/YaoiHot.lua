function Register()
	module.Name = "YaoiHot"
	module.Language = "en"

	module.Domains:Add("yaoihot.com")
end

function GetInfo()
	info.Title = dom:SelectValue("//h1")
	info.Author = dom:SelectValue('//strong[contains(text(),"Author:")]/following-sibling::text()')
	info.Tags = dom:SelectValues('//div[contains(@class,"genres-list")]/a')
	info.Summary = dom:SelectValue('(//div[contains(@class,"summary-content")])//p[last()]')
end

function GetChapters()
	for chapterNode in dom:SelectNodes('//a[contains(@class,"chapter-item")]') do
		local chapterUrl = chapterNode:SelectValue("./@href")
		local chapterTitle = chapterNode:SelectValue('.//span[contains(@class,"chapter-title")]')

		chapters:Add(chapterUrl, chapterTitle)
	end

	chapters:Reverse()
end

function GetPages()
	pages:AddRange(dom:SelectValues('//div[contains(@class,"reader-page")]//img/@src'))
end
