local function getPageDataJson()
	local pageDataStr = dom:SelectValue('//div[@id="app"]/@data-page')

	local js = JavaScript.New()
	local pageDataObject = js:Execute("pageData = " .. pageDataStr)

	return pageDataObject:ToJson()
end

function Register()
	module.Name = "Manhwa18"
	module.Adult = true
	module.Language = "en"
	module.Type = "Manhwa"

	module.Domains:Add("manhwa18.net")
end

function GetInfo()
	local json = getPageDataJson()

	info.Title = json:SelectValue("props.manga.name")
	info.AlternativeTitle = json:SelectValue("props.manga.other_name")
	info.Summary = json:SelectValue("props.manga.pilot")
	info.Status = json:SelectValue("props.manga.status_id") == "1" and "Ongoing" or "Completed"
	info.Tags = json:SelectValues("props.manga.genres[*].name")
	info.Artist = json:SelectValues("props.manga.artists[*].name")
	info.Characters = json:SelectValues("props.manga.characters[*].name")

	if isempty(info.Title) then
		-- Assume a chapter URL was added instead.
		local mangaName = json:SelectValue("props.mangaName")
		local chapterName = json:SelectValue("props.chapterName")

		info.Title = mangaName .. " - " .. chapterName
	end
end

function GetChapters()
	local json = getPageDataJson()
	local gallerySlug = json:SelectValue("props.manga.slug")

	for chapterNode in json:SelectNodes("props.chapters[*]") do
		local chapterSlug = chapterNode:SelectValue("slug")
		local chapterUrl = "/manga/" .. gallerySlug .. "/" .. chapterSlug
		local chapterTitle = chapterNode:SelectValue("name")

		chapters:Add(chapterUrl, chapterTitle)
	end

	chapters:Reverse()
end

function GetPages()
	local json = getPageDataJson()

	dom = Dom.New(json:SelectValue("props.chapterContent"))

	pages:AddRange(dom:SelectValues("//img/@src"))
end
