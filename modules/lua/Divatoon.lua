function Register()
	module.Name = "Divatoon"
	module.Language = "English"

	module.Domains:Add("divatoon.com")
	module.Domains:Add("www.divatoon.com")
end

function GetInfo()
	info.Title = dom:SelectValue("//h1")
	info.Description = dom:SelectValue('//div[contains(@class,"synopsis") or contains(@class,"description")]')
	info.Author = dom:SelectValue('//span[contains(text(),"Author")]/following-sibling::*[1]')
	info.Artist = dom:SelectValue('//span[contains(text(),"Artist")]/following-sibling::*[1]')
	info.Status = dom:SelectValue('//span[contains(text(),"Status")]/following-sibling::*[1]')
	info.Tags = dom:SelectValues('//a[contains(@href,"/genre/") or contains(@href,"/tag/")]')
	info.Scanlator = "Diva Scans"
	info.Url = url
end

function GetChapters()
	for chapterNode in dom:SelectElements('//a[contains(@href,"/chapter-")]') do
		local href = chapterNode:SelectValue("@href")
		local title = chapterNode:SelectValue(".//text()")

		if title then
			title = title:trim()
		end

		if href and href:find("/series/") then
			local fullUrl = "https://divatoon.com" .. href
			chapters:Add(fullUrl, title or href)
		end
	end

	chapters:Reverse()
end

function GetPages()
	pages:AddRange(dom:SelectValues('//img[contains(@src,"storage.divatoon.com/public/upload/series")]/@src'))

	if isempty(pages) then
		pages:AddRange(dom:SelectValues('//img[contains(@data-src,"storage.divatoon.com")]/@data-src'))
	end

	if isempty(pages) then
		pages:AddRange(dom:SelectValues('//img[contains(@src,"wsrv.nl") and contains(@src,"storage.divatoon")]/@src'))
	end

	if isempty(pages) then
		pages:AddRange(dom:SelectValues('//img[contains(@alt,"Page") or contains(@alt,"page")]/@src'))
	end
end
