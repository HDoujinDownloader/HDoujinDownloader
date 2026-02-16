local function getLanguageFromTitle(title)
	title = tostring(title):lower():trim()

	if title:endswith("raw") then
		return "Korean"
	elseif title:endswith("engsub") then
		return "English"
	end

	return ""
end

function Register()
	module.Name = "Manhua18"
	module.Adult = true
	module.Language = "English"

	module.Domains:Add("manhwa18.com")
end

function GetInfo()
	info.Title = dom:SelectValue('//span[contains(@class,"series-name")]')
	info.AlternativeTitle = dom:SelectValue('//span[contains(text(),"Other name")]/following-sibling::span')
	info.Tags = dom:SelectValues('//span[contains(text(),"Genre")]/following-sibling::span/a')
	info.Author = dom:SelectValues('//span[contains(text(),"Author")]/following-sibling::span/a')
	info.Status = dom:SelectValues('//span[contains(text(),"Status")]/following-sibling::span/a')
	info.Summary = dom:SelectValue('//div[contains(@class,"summary-content")]')
	info.Language = getLanguageFromTitle(info.Title)
end

function GetChapters()
	for chapterNode in dom:SelectNodes('//ul[contains(@class,"list-chapters")]/a') do
		local chapterUrl = chapterNode:SelectValue("@href")
		local chapterTitle = chapterNode.SelectValue('.//div[contains(@class,"chapter-name")]')

		chapters.Add(chapterUrl, chapterTitle)
	end

	chapters.Reverse()
end

function GetPages()
	pages.AddRange(dom:SelectValues('//div[@id="chapter-content"]//img/@data-src'))
end
