function Register()

    module.Name = 'JapScan'
    module.Language = 'French'

    module.Domains.Add('japscan.co')
    module.Domains.Add('japscan.cc')
    module.Domains.Add('japscan.com')
    module.Domains.Add('japscan.to')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.OriginalTitle = dom.SelectValue('//span[contains(text(), "Nom Original")]/following-sibling::text()')
    info.AlternativeTitle = dom.SelectValues('//span[contains(text(), "Nom(s) Alternatif(s)")]/following-sibling::a')
    info.Status = dom.SelectValue('//span[contains(text(), "Statut")]/following-sibling::text()')
    info.DateReleased = dom.SelectValue('//span[contains(text(), "Date Sortie")]/following-sibling::text()')
    info.Tags = dom.SelectValues('//span[contains(text(), "Genre(s)") or contains(text(), "Type(s)")]/following-sibling::text()')
    info.Artist = dom.SelectValue('//span[contains(text(), "Artiste(s)")]/following-sibling::text()')
    info.Author = dom.SelectValue('//span[contains(text(), "Auteur(s)")]/following-sibling::text()')
    info.Summary = dom.SelectValue('//div[contains(text(), "Synopsis")]/following-sibling::p/text()')

    if(info.Title:startswith('Manga')) then
        info.Type = 'Manga'
    elseif(info.Title:startswith('Manhua')) then
        info.Type = 'Manhua'
    elseif(info.Title:startswith('Manhwa')) then
        info.Type = 'Manhwa'
    end

    info.Title = CleanTitle(info.Title)

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//div[@id="chapters_list"]//a'))

    for chapter in chapters do
        chapter.Title = CleanTitle(chapter.Title) -- Remove "VF"
    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(dom.SelectValues('//option/@data-img'))

end

function CleanTitle(title)

    title = RegexReplace(title, '^Man(?:g|hu|hw)a|VF$', '')
    title = RegexReplace(title, '\\sVF:', ' :')

    return title

end
