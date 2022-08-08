-- This module is very similar to the one used for AsmHentai (AsmHentai.lua).
-- It is not identical, however, because the API requires different parameters.

require "AsmHentai"

function Register()

    module.Name = 'HentaiEra'
    module.Adult = true

    module.Domains.Add('hentaiera.com')

end

function GetThumbnailUrls()

    -- Make request to get session cookies.

    dom = dom.New(http.Get(url))

    -- Get thumbnail URLs through the API.

    local apiEndpoint = '//' .. module.Domain .. '/inc/thumbs_loader.php'
    local galleryId = GetGalleryId(url)
    local server = dom.SelectValue('//input[@id="load_server"]/@value')
    local loadId = dom.SelectValue('//input[@id="load_id"]/@value')
    local loadDir = dom.SelectValue('//input[@id="load_dir"]/@value')
    local totalPages = GetPageCount()

    -- Galleries with < 10 pages will not have a "load_dir" value, so we can just get the thumbnails directly.

    if(not isempty(loadDir)) then

        http.Headers['Accept'] = '*/*'
        http.Headers['X-Requested-With'] = 'XMLHttpRequest'
    
        http.PostData['server'] = server
        http.PostData['u_id'] = galleryId
        http.PostData['g_id'] = loadId
        http.PostData['img_dir'] = loadDir
        http.PostData['visible_pages'] = '0'
        http.PostData['total_pages'] = tostring(totalPages)
        http.PostData['type'] = '2'

        local apiResponse = http.Post(apiEndpoint)

        dom = dom.New(apiResponse)

    end

    return dom.SelectValues('//div[contains(@class,"gthumb")]//img/@data-src')

end
