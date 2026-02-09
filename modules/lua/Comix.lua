local API_PATH = "/api/v2/"

local function getApiJson(path)
	path = API_PATH .. path

	http.Headers["accept"] = "*/*"
	http.Headers["content-type"] = "application/json"

	return Json.New(http:Get(path))
end

function Register()
	module.Name = "Comix"
	module.Language = "en"

	module.Domains:Add("comix.to")
end

function GetInfo()
	info.Title = dom:SelectValue("//h1")
	info.AlternativeTitle = dom:SelectValue("//h3"):split("/")
	info.Summary = dom:SelectValue('//div[contains(@class,"description")]')
	info.Type = dom:SelectValues('//div[contains(text(),"Type:")]//a')
	info.Author = dom:SelectValue('//div[contains(text(),"Authors:")]//a')
	info.Artist = dom:SelectValue('//div[contains(text(),"Artists:")]//a')
	info.Genres = dom:SelectValue('//div[contains(text(),"Genres:")]//a')
end

function GetChapters()
	local slug = url:regex("\\/title\\/([^\\/]+)", 1)
	local slugPrefix = slug:regex("(.+?)-", 1)
	local chapterCount = 0
	local chaptersPerPage = 20
	local currentPageIndex = 1

	repeat
		local path = "manga/" .. slugPrefix .. "/chapters?limit=" .. chaptersPerPage .. "&page=" .. currentPageIndex .. "&order[number]=desc"
		local json = getApiJson(path)

		local newChapterCount = tonumber(json:SelectValue("result.pagination.total"))
		local chapterNodes = json:SelectNodes("result.items[*]")
		if chapterNodes:Count() <= 0 then
			break
		end

		for chapterNode in chapterNodes do
			local chapterId = chapterNode:SelectValue("chapter_id")
			local chapterUrl = "/title/" .. slug .. "/" .. chapterId
			local chapterNumber = chapterNode:SelectValue("number")
			local chapterTitle = "Ch. " .. chapterNumber
			local chapterSubtitle = chapterNode:SelectValue("name")
			local chapterLanguage = chapterNode:SelectValue("language")
			local chapterVolumeNumber = tonumber(chapterNode:SelectValue("volume"))
			local chapterScanlator = chapterNode:SelectValue("scanlation_group.name")

			if not isempty(chapterSubtitle) then
				chapterTitle = chapterTitle .. " - " .. chapterSubtitle
			end

			local chapterInfo = ChapterInfo.New()
			chapterInfo.Url = chapterUrl
			chapterInfo.Title = chapterTitle
			chapterInfo.Language = chapterLanguage
			chapterInfo.Scanlator = chapterScanlator

			if chapterVolumeNumber and chapterVolumeNumber > 0 then
				chapterInfo.Volume = chapterVolumeNumber
			end

			chapters:Add(chapterInfo)
		end

		if newChapterCount then
			chapterCount = newChapterCount
		end

		currentPageIndex = currentPageIndex + 1
	until chapters:Count() >= chapterCount

	chapters:Reverse()
end

function GetPages()
	local imagesScript = dom:SelectValue('//script[contains(.,"images")]')
	for imageUrl in imagesScript:regexmany('\\\\"url\\\\":\\\\"([^"\\\\]+)', 1) do
		pages:Add(imageUrl)
	end

	pages:Sort()
end
