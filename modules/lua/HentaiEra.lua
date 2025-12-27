-- This module is very similar to AsmHentai and IMHentai.
-- However, the metadata and images URLs must be acccessed differently.

local function ensureOnGalleryPage()
	local backToGalleryUrl = dom.SelectValue('//a[contains(@class,"return_btn") or contains(@class,"back_btn")]/@href')
	if not isempty(backToGalleryUrl) then
		url = backToGalleryUrl
		dom = Dom.New(http.Get(url))
	end
end

local function getFileExtensionFromKey(key)
	if key == "j" then
		return ".jpg"
	elseif key == "p" then
		return ".png"
	elseif key == "b" then
		return ".bmp"
	elseif key == "g" then
		return ".gif"
	elseif key == "w" then
		return ".webp"
	end

	return ".jpg"
end

function Register()
	module.Name = "HentaiEra"
	module.Adult = true

	module.Domains:Add("hentaiera.com")
end

function GetInfo()
	ensureOnGalleryPage()

	info.Title = dom.SelectValue("//h1")
	info.OriginalTitle = dom.SelectValue('//p[contains(@class,"subtitle")]')
	info.Tags = dom.SelectValues('//span[contains(text(),"Tags")]/following-sibling::div//a')
	info.Circle = dom.SelectValues('//span[contains(text(),"Groups")]/following-sibling::div//a')
	info.Language = dom.SelectValues('//span[contains(text(),"Languages")]/following-sibling::div//a')
	info.Type = dom.SelectValues('//span[contains(text(),"Category")]/following-sibling::div//a')
	info.Url = url
end

function GetPages()
	-- Instead of computing the image server using the reader parameters, we can just use a thumbnail URL as a template.
	-- Thumbnails will be stored on the same server as the full size images.

	local imageBaseUrl = dom.SelectValue('//div[contains(@class,"gthumb") or contains(@class,"gp_th")]//img/@data-src'):beforelast("/") .. "/"
	local imagesJsonStr = dom.SelectValue('//script[contains(text(),"g_th")]'):regex("parseJSON\\('(.+?)'\\);", 1)

	if not isempty(imageBaseUrl) and not isempty(imagesJsonStr) then
		local imagesJson = Json.New(imagesJsonStr)

		for key in imagesJson.Keys do
			-- Image data is represented as a 3-tuple in the form "format,width,height".
			local fileExtensionKey = tostring(imagesJson[key]):split(",")[0]
			local fileExtension = getFileExtensionFromKey(fileExtensionKey)
			local imageUrl = imageBaseUrl .. key .. fileExtension

			pages.Add(imageUrl)
		end
	end
end
