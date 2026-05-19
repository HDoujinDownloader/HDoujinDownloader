local function isGalleryUrl()
	return url:contains("/g/") or url:contains("/d/") -- 3hentai.net
end

local function getGalleryId()
	-- 3hentai.net uses "/d/" instead of "/g/"
	return url:regex("\\/[gd]\\/(\\d+)", 1)
end

local function getGalleryPrettyTitle()
	local prettyTitle = dom:SelectValue('//span[contains(@class,"pretty")]')

	if isempty(prettyTitle) then -- 3hentai.net
		prettyTitle = dom:SelectValue('//span[contains(@class,"middle-title")]')
	end

	if isempty(prettyTitle) then -- nhentai.uk
		prettyTitle = RegexReplace(dom:SelectValue('//div[@id="bigcontainer"]//h1'):trim(), "(?i)(?:^Nhentai|hentai$)", "")
	end

	-- nhentai.xxx doesn't have a "pretty" title, but we can extract the English title instead.
	if isempty(prettyTitle) then
		prettyTitle = dom:SelectValue("//h1"):after("|")
	end

	return tostring(prettyTitle):trim()
end

local function getGalleryTitle()
	local title

	if toboolean(module.Settings["Use pretty titles"]) then
		title = getGalleryPrettyTitle()
	end

	if isempty(title) then -- nhentai.uk
		title = dom:SelectValue('//div[@id="info"]/h1')
	end

	if isempty(title) then
		title = dom:SelectValue("//h1")
	end

	-- Fall back to the gallery ID if we can't get a title.
	if isempty(title) then
		title = getGalleryId()
	end

	return title
end

local function getGalleryTags(groupName)
	local tagsPatterns = {
		'//div[contains(@class, "tag-container") and contains(text(), "' .. groupName .. '")]//span[contains(@class,"name")]',
		'//div[contains(@class, "tag-container") and contains(text(), "' .. groupName .. '")]//a',
		'//span[contains(text(),"' .. groupName .. '")]/following-sibling::a//span[contains(@class,"tag_name")]', -- nhentai.xxx
	}

	for _, tagsPattern in ipairs(tagsPatterns) do
		local tags = dom:SelectValues(tagsPattern)
		if not isempty(tags) then
			return tags
		end
	end
end

local function getGalleryPageCount()
	return dom:SelectValue('//span[contains(@class,"tag_name") and contains(@class,"pages")]') -- nhentai.xxx
end

local function getGalleryThumbnailUrls()
	local thumbnailUrls = dom:SelectValues('//div[@id="thumbnail-container"]//img/@data-src')

	if isempty(thumbnailUrls) then -- 3hentai.net
		thumbnailUrls = dom:SelectValues('//div[@id="thumbnail-gallery"]//img/@data-src')
	end

	if isempty(thumbnailUrls) then -- simplyhentai.org
		thumbnailUrls = dom:SelectValues('//div[@class="thumb-container"]//img/@src')
	end

	if isempty(thumbnailUrls) then -- nhentai.xxx
		thumbnailUrls = dom:SelectValues('//div[contains(@class,"gallery_thumbs")]//img/@data-src')
	end

	return thumbnailUrls
end

local function getGalleryReaderUrls()
	-- Get the reader URLs for each image in the gallery.
	-- nhentai.xxx uses the same thumbnail loader as AsmHentai, so we can't extract them all from the page without an API call.

	local pageCount = tonumber(getGalleryPageCount())
	local pageList = List.New()

	if pageCount then
		local baseUrl = url:trim("/")

		for i = 1, pageCount do
			pageList.Add(baseUrl .. "/" .. tostring(i) .. "/")
		end

		return pageList
	else
		-- Extract the reader URLS directly from the page.
		return dom:SelectValues('//div[contains(@class,"gallery_thumbs")]//a/@href') -- nhentai.xxx
	end
end

local function redirectToGalleryPage()
	local backToGalleryUrl = dom:SelectValue('//*[contains(@class,"back-to-gallery") or contains(@class,"go-back")]//@href')

	if isempty(backToGalleryUrl) then -- nhentai.xxx
		backToGalleryUrl = dom:SelectValue('//a[contains(@class,"back_btn")]/@href')
	end

	if not isempty(backToGalleryUrl) then
		local src = http.Get(backToGalleryUrl)

		dom = Dom.New(src)
	end
end

local function enqueueAllGalleries(dom)
	for galleryUrl in dom:SelectValues('//div[contains(@class,"container")][last()]//div[contains(@class,"gallery")]/a/@href') do
		Enqueue(galleryUrl)
	end
end

function Register()
	module.Name = "nhentai"
	module.Adult = true

	module.Domains:Add("nhentai.net")

	module.Domains:Add("3hentai.net", "3hentai")
	module.Domains:Add("es.3hentai.net", "3hentai")
	module.Domains:Add("fra.3hentai.net", "3hentai")
	module.Domains:Add("hitomila.to", "Hitomila")
	module.Domains:Add("it.3hentai.net", "3hentai")
	module.Domains:Add("nhentai.to")
	module.Domains:Add("nhentai.uk")
	module.Domains:Add("nhentai.xxx")
	module.Domains:Add("pt.3hentai.net", "3hentai")
	module.Domains:Add("ru.3hentai.net", "3hentai")
	module.Domains:Add("simplyhentai.org", "Simply Hentai")

	module.Settings.AddCheck("Use pretty titles", false).WithToolTip("Use shorter titles with the artist, series, and language information removed.")
end

function GetInfo()
	if isGalleryUrl() then
		redirectToGalleryPage()

		info.Title = getGalleryTitle()
		info.OriginalTitle = dom:SelectValue('//div[@id="info" or @class="info"]/h2')
		info.Tags = getGalleryTags("Tags")
		info.Circle = tostring(getGalleryTags("Groups")):title()
		info.Artist = tostring(getGalleryTags("Artists")):title()
		info.Parody = tostring(getGalleryTags("Parodies")):title()
		info.Characters = getGalleryTags("Characters")
		info.Language = getGalleryTags("Languages")
		info.Type = getGalleryTags("Categories")
	else
		-- The user added their favorites, a tag, or a search URL.
		info.Ignore = true

		local maxScrapingDepth = global.GetSetting("Downloads.MaxScrapingDepth")

		if isempty(maxScrapingDepth) then
			maxScrapingDepth = 1
		end

		local depth = 0

		for page in Paginator.New(http, dom, '//section[contains(@class,"pagination")]/a[contains(@class,"next")]/@href') do
			enqueueAllGalleries(page)

			depth = depth + 1

			if depth >= tonumber(maxScrapingDepth) then
				break
			end
		end
	end
end

function GetPages()
	redirectToGalleryPage()

	local replaceImageServer = module.Domain ~= "nhentai.to"
	local deferImageUrl = module.Domain == "nhentai.xxx"

	if deferImageUrl then
		-- We can't determine the full image URL from the thumbnail, so we'll get it later (nhentai.xxx).
		-- This is because the file extension can vary (.webp, .png, etc.).
		for pageUrl in getGalleryReaderUrls() do
			local pageInfo = PageInfo.New(pageUrl)

			pageInfo.Data["lazy"] = true

			pages.Add(pageInfo)
		end
	else
		-- Convert the thumbnail URLs to full image URLs.
		for thumbnailUrl in getGalleryThumbnailUrls() do
			local fullImageUrl = thumbnailUrl

			-- Adjust the image server from the thumbnail server to the image server (e.g. "t1" -> "i1").
			if replaceImageServer then
				fullImageUrl = RegexReplace(fullImageUrl, "\\/\\/t(\\d?)\\.", "//i$1.")
			end

			-- Remove the thumbnail prefix from the file name.
			fullImageUrl = RegexReplace(fullImageUrl, "(\\d+)t(.+?)$", "$1$2")

			-- Newer galleries on NHentai will have ".webp" appended to the original file extension (e.g. ".jpg.webp").
			-- We need to strip the extraneous file extension.
			fullImageUrl = RegexReplace(fullImageUrl, "\\.(jpg|png|gif|webp)\\.webp$", ".$1")

			pages.Add(fullImageUrl)
		end
	end
end

function BeforeDownloadPage()
	if not page.Data or isempty(page.Data["lazy"]) then
		return
	end

	page.Url = dom:SelectValue('//img[contains(@id,"fimg")]/@data-src')
end

function Login()
	if isempty(http.Cookies) then
		local domain = module.Domain
		local loginUrl = "https://" .. domain .. "/login/"

		http.Headers["Origin"] = "https://" .. module.Domain
		http.Headers["Referer"] = "https://" .. module.Domain .. "/login/?next=/"

		local dom = Dom.New(http.Get(loginUrl))

		http.PostData.Add("username_or_email", username)
		http.PostData.Add("password", password)
		http.PostData.Add("csrfmiddlewaretoken", dom:SelectValue('//input[@name="csrfmiddlewaretoken"]/@value'))
		http.PostData.Add("next", "/")

		local response = http.PostResponse(loginUrl)

		if not response.Cookies.Contains("sessionid") then
			Fail(Error.LoginFailed)
		end

		global.SetCookies(response.Cookies)
	end
end
