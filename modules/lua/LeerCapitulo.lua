function Register()

    module.Name = 'leercapitulo.co'
    module.Language = 'Spanish'

    module.Domains.Add('leercapitulo.co')
    module.Domains.Add('www.leercapitulo.co')

end

local function deobfuscatePageArray(arrayData)

    local js = JavaScript.New()

    js.Execute('data = "' .. arrayData .. '"')

   local result = js.Execute('atob(data.replace(/[A-Z0-9]/gi,function(e){return"x5RwpZakGjeDEtU7WzYnJFCcgS1Kv9hN28OPAuTiBHy4fbVIModsXq0mQL36rl"["glJ8W7UX6c5uMLBeCxFjpb4NGKEsvPrR19Va3YnyqHtzo0iDZOdIkT2ASQwhmf".indexOf(e)];})).split(",");')

   return result.ToJson()

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.AlternativeTitle = dom.SelectValue('//span[contains(text(),"Títulos Alternativos")]/following-sibling::text()'):split(',')
    info.Tags = dom.SelectValue('//span[contains(text(),"Géneros")]/following-sibling::a')
    info.Type = dom.SelectValue('//span[contains(text(),"Escribe")]'):after(':')
    info.Status = dom.SelectValue('//span[contains(text(),"Estado")]/following-sibling::text()')
    info.Summary = dom.SelectValue('//p[contains(@id,"example2")]/text()[1]')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//div[contains(@class,"chapter-list")]//div[contains(@class,"chapter")]//a'))

    chapters.Reverse()

end

function GetPages()

    local arrayData = dom.SelectValue('//p[contains(@id,"array_data")]'):trim()
    local pagesJson = deobfuscatePageArray(arrayData)

    for pageUrl in pagesJson.SelectValues('[*]') do
        pages.Add(pageUrl)
    end

end
