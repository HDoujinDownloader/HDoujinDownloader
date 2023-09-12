-- This module is very similar to AsmHentai and IMHentai.
-- However, the metadata and images URLs must be acccessed differently.

function Register()

    module.Name = 'HentaiEra'
    module.Adult = true

    module.Domains.Add('hentaiera.com')

end

function GetInfo()

    RedirectBackToGallery()

    info.Title = dom.SelectValue('//h1')
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

    local imageBaseUrl = dom.SelectValue('//div[contains(@class,"gthumb")]//img/@data-src')
        :beforelast('/') .. '/'

    local imagesJsonStr = dom.selectValue('//script[contains(text(),"g_th")]')
        :regex("parseJSON\\('(.+?)'\\);", 1)

    if(not isempty(imageBaseUrl) and not isempty(imagesJsonStr)) then

        local imagesJson = Json.New(imagesJsonStr)
        
        for key in imagesJson.Keys do

            local fileExtensionKey = tostring(imagesJson[key]):split(',')[0]
            local fileExtension = GetFileExtensionFromKey(fileExtensionKey)
            local imageUrl = imageBaseUrl .. key .. fileExtension

            pages.Add(imageUrl)

        end

    end

end

function RedirectBackToGallery()

    local backToGalleryUrl = dom.SelectValue('//a[contains(@class,"return_btn") or contains(@class,"back_btn")]/@href')

    if(not isempty(backToGalleryUrl)) then

        url = backToGalleryUrl
        dom = Dom.New(http.Get(url))

    end

end

function GetFileExtensionFromKey(key)

    if(key == 'j') then 
        return '.jpg'
    elseif(key == 'p') then 
        return '.png'
    elseif(key == 'b') then 
        return '.bmp'
    elseif(key == 'g') then 
        return '.gif'
    else
        return '.jpg'
    end

end
