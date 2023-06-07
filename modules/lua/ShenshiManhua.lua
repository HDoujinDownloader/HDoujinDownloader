function Register()

    module.Name = '紳士漫畫'
    module.Language = 'chinese'
    module.Adult = true

    module.Domains.Add('wnacg.com')
    module.Domains.Add('www.wnacg.com')

end

function GetInfo()

    info.Title = dom.SelectValue('//h2')
    info.Type = dom.SelectValue('//label[contains(text(),"分類：")]')
        :after('：')
        :before('／')
        :before('&')
    info.Tags = dom.SelectValues('//a[contains(@class,"tagshow")]')
    info.Summary = dom.SelectValue('//p[contains(text(),"簡介：")]')
        :after('：')
    info.PageCount = dom.SelectValue('//label[contains(text(),"頁數：")]'):regex('(\\d+)', 1)

end

function GetPages()

    for page in Paginator.New(http, dom, '//span[@class="next"]/a/@href') do
    
        pages.AddRange(page.SelectValues('//li[contains(@class,"gallary_item")]//a/@href'))
    
    end

end

function BeforeDownloadPage()

    dom = Dom.New(http.Get(page.Url))

    page.Url = dom.SelectValue('//img[@id="picarea"]/@src')

end
