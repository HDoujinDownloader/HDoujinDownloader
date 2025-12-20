local function loadModule(name)
	require(name)

	return {
		GetInfo = GetInfo,
		GetChapters = GetChapters,
		GetPages = GetPages,
	}
end

local AnyAcgV1 = loadModule("AnyAcgV1")
local AnyAcgV2 = loadModule("AnyAcgV2")
local AnyAcgV4 = loadModule("AnyAcgV4")

local function isAnyAcgV2()
	return url:contains("/series/") or url:contains("/chapter/")
end

local function isAnyAcgV4()
	return dom:SelectNodes('//div[contains(@data-name,"chapter-list")]|//script[contains(@type,"qwik/json") and contains(text(),"image_server")]'):Count() > 0
end

local function pickBaseModule()
	if isAnyAcgV2() then
		return AnyAcgV2
	elseif isAnyAcgV4() then
		return AnyAcgV4
	end

	return AnyAcgV1
end

function Register()
	module.Name = "AnyACG"

	module.Domains:Add("bato.ing", "BATO.TO")
	module.Domains:Add("bato.red", "BATOTO")
	module.Domains:Add("bato.si", "BATOTO")
	module.Domains:Add("bato.to", "BATO.TO")
	module.Domains:Add("batocomic.org", "BATOTO")
	module.Domains:Add("batotoo.com", "BATO.TO")
	module.Domains:Add("batotoo.com", "BATOTO")
	module.Domains:Add("battwo.com", "BATOTO")
	module.Domains:Add("battwo.com", "Bato.To")
	module.Domains:Add("comiko.net", "BATO.TO")
	module.Domains:Add("comiko.net", "Bato.To")
	module.Domains:Add("dto.to", "BATO.TO")
	module.Domains:Add("hto.to", "BATOTO")
	module.Domains:Add("jto.to", "BATO.TO")
	module.Domains:Add("kuku.to", "BATOTO")
	module.Domains:Add("mangaseinen.com", "mangaseinen.com")
	module.Domains:Add("mangatensei.com", "MangaTensei.com")
	module.Domains:Add("mangatoto.com", "BATO.TO")
	module.Domains:Add("mto.to", "BATOTO")
	module.Domains:Add("okok.to", "BATOTO")
	module.Domains:Add("rawmanga.info", "raw manga")
	module.Domains:Add("readtoto.org", "BATOTO")
	module.Domains:Add("ruru.to", "BATOTO")
	module.Domains:Add("wto.to", "BATO.TO")
	module.Domains:Add("xbato.com", "BATOTO")
	module.Domains:Add("xbato.net", "BATOTO")
	module.Domains:Add("zbato.net", "BATO.TO")
	module.Domains:Add("zbato.org", "BATO.TO")
end

function GetInfo()
	local baseModule = pickBaseModule()
	baseModule.GetInfo()
end

function GetChapters()
	local baseModule = pickBaseModule()
	baseModule.GetChapters()
end

function GetPages()
	local baseModule = pickBaseModule()
	baseModule.GetPages()
end
