function Register()

    module.Name = 'TimelessLeaf'
    module.Language = 'English'
    module.Type = 'Manhua'

    module.Domains.Add('timelessleaf.com')

end

function GetInfo()

    info.Title = dom.SelectElement('//h1[@class="entry-title"]')
    info.Summary = dom.SelectElements('//div[contains(@class, "entry-content")]//p[not(contains(.,"Chapter")) and not(descendant::strong)]').Join('\n\n'):after('Summary:')
    info.Scanlator = 'TimelessLeaf'
    info.Translator = 'TimelessLeaf'
    
end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//div[contains(@class, "entry-content")]//a'))

end

function GetPages()

    pages.AddRange(dom.SelectValues('//div[contains(@class, "entry-content")]//img/@src'))

end
