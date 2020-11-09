-- This module doesn't yet support adding galleries from tag pages or search results, so temporarily disable it if that's a feature you need.

function Register()

	module.Name = 'Hitomi.la'
	module.Adult = true

	module.Domains.Add('hitomi.la', 'Hitomi.la')

end

function GetInfo()

	local galleryId = GetGalleryId(url)
	local json = GetGalleryJson(galleryId)

	info.Title = json['title']
	info.OriginalTitle = json['japanese_title']
	info.Language = json['language']
	info.Tags = json.SelectValues('tags[*].tag')
	
	if(isempty(info.Title)) then
		info.Title = 'Gallery '..GetGalleryId(galleryId)
	end

	if(info.OriginalTitle == 'null') then
		info.OriginalTitle = ''
	end

	-- Some information (group, series, artist, characters) is only available directly on the gallery page.

	info.Circle = dom.SelectValues('//td[contains(text(),"Group")]/following-sibling::*//a')
	info.Series = dom.SelectValues('//td[contains(text(),"Series")]/following-sibling::*//a')
	info.Artist = dom.SelectValues('//h2//a')
	info.Characters = dom.SelectValues('//td[contains(text(),"Characters")]/following-sibling::*//a')
	info.Type = dom.SelectValues('//td[contains(text(),"Type")]/following-sibling::*//a')
	info.Parody = info.Series

end

function GetPages()

	local js = JavaScript.New()

	local galleryId = GetGalleryId(url)
	local galleryJs = GetGalleryJs(galleryId)
	local commonJs = http.Get('//ltn.hitomi.la/common.js'):regex("'\\.nozomi';(.+)\\$\\(document\\)", 1)

	js.Execute(galleryJs)	
	js.Execute(commonJs)

	local imageUrls = js.Execute(
		'(function () {'..
		'	imageUrls = [];'..
		'	galleryinfo["files"].forEach(function(image) {'..
		'		imageUrls.push(url_from_url_from_hash('..galleryId..', image));'..
		'	});'..
		'	return imageUrls;'..
		'})();'
	)
	
	pages.AddRange(imageUrls.ToJson().SelectValues('[*]'))

end

function GetGalleryId(url)

	return url:regex('(\\d+)\\.html', 1)

end

function GetGalleryJs(galleryId)

	local jsUrl = '//ltn.hitomi.la/galleries/'..galleryId..'.js'
	local galleryJs = http.Get(jsUrl)

	return galleryJs

end

function GetGalleryJson(galleryId)

	local galleryJs = GetGalleryJs(galleryId)
	local galleryJson = galleryJs:regex('var\\s+galleryinfo\\s+=\\s(.+)', 1)

	return Json.New(galleryJson)

end
