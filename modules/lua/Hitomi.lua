function Register()

	module.Name = 'Hitomi.la'
	module.Adult = true

	module.Domains.Add('hitomi.la', 'Hitomi.la')

	module.Settings.AddCheck('Use friendly filenames', true)
        .WithToolTip('If enabled, the original filename will be a friendly name based on the file metadata instead of the file hash.')

end

function GetInfo()

	-- If we're being redirected, follow the redirect to the final page (URLs without gallery title redirect to URLs with gallery titles).
	-- It's important to follow the redirect in order to get all metadata fields.

	local redirectUrl = dom.SelectValue('//meta[@http-equiv="refresh"]/@content'):after('url=')

	if(not isempty(redirectUrl)) then
		
		url = redirectUrl
		dom = Dom.New(http.Get(url))

	end

	local galleryId = GetGalleryId(url)

	if(not isempty(galleryId)) then

		-- The user added a gallery or reader URL.

		local json = GetGalleryJson(galleryId)

		info.Url = url
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
	
		info.Circle = tostring(dom.SelectValues('//td[contains(text(),"Group")]/following-sibling::*//a')):title()
		info.Series = tostring(dom.SelectValues('//td[contains(text(),"Series")]/following-sibling::*//a')):title()
		info.Artist = tostring(dom.SelectValues('//h2//a')):title()
		info.Characters = dom.SelectValues('//td[contains(text(),"Characters")]/following-sibling::*//a')
		info.Type = tostring(dom.SelectValues('//td[contains(text(),"Type")]/following-sibling::*//a')):title()
		info.Parody = info.Series

	else

		-- The user added a tag URL.
		-- e.g. https://hitomi.la/tag/artbook-all.html?page=2

		local pageNumber = GetParameter(url, 'page')

		if(isempty(pageNumber)) then
			pageNumber = '1'
		end

		local galleriesPerPage = 25	
		local startByte = (tonumber(pageNumber) - 1) * galleriesPerPage * 4
		local endByte = startByte + galleriesPerPage * 4 - 1

		http.Headers['Range'] = 'bytes='..startByte..'-'..endByte
		http.Headers['accept'] = '*/*'
		http.Headers['accept-encoding'] = 'identity'

		local nozomi = http.GetResponse(GetNozomiAddress(url)).Data
		local total = nozomi.Count() / 4
		local galleryIds = List.New()

		for i = 0, total - 1 do
			galleryIds.Add(nozomi.GetUInt32(i * 4))
		end

		for galleryId in galleryIds do
			Enqueue('/galleries/'..galleryId..'.html')
		end

		info.Ignore = true

	end

end

function GetPages()

	local js = JavaScript.New()

	local galleryId = GetGalleryId(url)
	local galleryJs = GetGalleryJs(galleryId)
	local commonJs = http.Get('//ltn.hitomi.la/common.js'):regex("'\\.nozomi';(.+)\\$\\(document\\)", 1)

	js.Execute(galleryJs)	
	js.Execute(commonJs)

	local imageData = js.Execute(
		'(function () {'..
		'	imageData = [];'..
		'	galleryinfo["files"].forEach(function(image) {'..
		'		imageData.push([url_from_url_from_hash('..galleryId..', image), image.name]);'..
		'	});'..
		'	return imageData;'..
		'})();'
	).ToJson().SelectNodes('[*]')

	for i = 0, imageData.Count() - 1 do
		
		local page = PageInfo.New(imageData[i][0])

		if(toboolean(module.Settings['Use friendly filenames'])) then
			page.FilenameHint = imageData[i][1]
		end

		pages.Add(page)

	end

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

function GetNozomiAddress(url)

	local domain = 'ltn.'..module.Domain
	local filePath = DecodeUriComponent(url:after(module.Domain..'/'))
	local nozomiExtension = '.nozomi'

	return '//'..domain..'/'..filePath:before('.html')..nozomiExtension

end
