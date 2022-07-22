function Register()

    module.Name = '美图鉴赏'
    module.Adult = true
    module.Type = 'artist cg'

    module.Domains.Add('acg.lspimg.com')
    module.Domains.Add('lspimg.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//title')
        :beforelast('-')
        :beforelast('\\')

end

function GetPages()

    pages.AddRange(dom.SelectValues('//img/@src'))

end
