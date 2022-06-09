-- This module is very similar to the one used for IMHentai (IMHentai.lua).
-- It is not identical, however, because the server selection depends on different gallery ID ranges.

require "IMHentai"

function Register()

    module.Name = 'HentaiEra'
    module.Adult = true

    module.Domains.Add('hentaiera.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.OriginalTitle = dom.SelectValue('//p[contains(@class,"subtitle")]')
    info.Parody = dom.SelectValues('//span[contains(text(),"Parodies")]/following-sibling::div//a')
    info.Characters = dom.SelectValues('//span[contains(text(),"Characters")]/following-sibling::div//a')
    info.Tags = dom.SelectValues('//span[contains(text(),"Tags")]/following-sibling::div//a')
    info.Artist = dom.SelectValues('//span[contains(text(),"Artists")]/following-sibling::div//a')
    info.Language = dom.SelectValues('//span[contains(text(),"Languages")]/following-sibling::div//a')
    info.Type = dom.SelectValues('//span[contains(text(),"Category")]/following-sibling::div//a')

end

function GetImageServerFromGalleryId(galleryId)

    -- The logic that selects an image server is in main_XXXXXX.js.
    
    local imageServer = 'm5'

    if(galleryId > 0 and galleryId <= 274825) then
        imageServer = 'm1'
    elseif(galleryId > 274825 and galleryId <= 403818) then
        imageServer = 'm2'
    elseif(galleryId > 403818 and galleryId <= 527143) then
        imageServer = 'm3'
    elseif(galleryId > 527143 and galleryId <= 632481) then
        imageServer = 'm4'
    elseif(galleryId > 632481 and galleryId <= 815858) then
        imageServer = 'm5'
    elseif(galleryId > 815858) then
        imageServer = 'm6'
    end

    return imageServer

end
