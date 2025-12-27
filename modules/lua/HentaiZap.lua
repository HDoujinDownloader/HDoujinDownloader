-- This website is extremely similar to HentaiEra, but we need to get the metadata differently.

require("HentaiEra")

local function ensureOnGalleryPage()
	local backToGalleryUrl = dom.SelectValue('//a[contains(@class,"back_btn")]')
	if not isempty(backToGalleryUrl) then
		url = backToGalleryUrl
		dom = Dom.New(http:Get(url))
	end
end

local function getPageCount()
	return dom.SelectValue('//span[contains(@class,"info_pg")]'):regex("\\d+")
end

function Register()
	module.Name = "HentaiZap"
	module.Adult = true

	module.Domains:Add("hentaizap.com")
end

function GetInfo()
	ensureOnGalleryPage()

	info.Title = dom.SelectValue("//h1")
	info.Parody = dom.SelectValues('//span[contains(text(),"Parodies:")]/following-sibling::li//a/text()[1]')
	info.Characters = dom.SelectValues('//span[contains(text(),"Characters:")]/following-sibling::li//a/text()[1]')
	info.Tags = dom.SelectValues('//span[contains(text(),"Tags:")]/following-sibling::li//a/text()[1]')
	info.Artist = dom.SelectValues('//span[contains(text(),"Artists:")]/following-sibling::li//a/text()[1]')
	info.Language = dom.SelectValues('//span[contains(text(),"Languages:")]/following-sibling::li//a/text()[1]')
	info.Type = dom.SelectValues('//span[contains(text(),"Category:")]/following-sibling::li//a/text()[1]')
	info.PageCount = getPageCount()
end
