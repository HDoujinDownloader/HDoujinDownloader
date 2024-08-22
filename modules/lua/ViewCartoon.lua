function Register()

    module.Name = 'ViewCartoon'
    module.Language = 'thai'

    module.Domains.Add('viewcartoon.com')

end

local function GetPdfDownloadUrl(dom)

    local pdfDownloadUrl = dom.SelectValue('//script[contains(text(), "initPDFViewer")]')
        :regex('initPDFViewer\\("([^"]+)"', 1)

    if(not isempty(pdfDownloadUrl)) then
        pdfDownloadUrl = '/manga/' .. pdfDownloadUrl .. '.jpg'
    end

    return pdfDownloadUrl

end

local function GetPdfPageInfo(dom)

    local pageInfo = PageInfo.New(GetPdfDownloadUrl(dom))

    pageInfo.ExtractContents = true
    pageInfo.FileExtensionHint = '.pdf'

    return pageInfo

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')
    info.Summary = dom.SelectValue('//h1/following-sibling::p[string-length(text()) > 0]')
    info.Tags = dom.SelectValue('//p[contains(.,"tag:")]/text()')

end

function GetChapters()

    chapters.AddRange(dom.SelectElements('//a[@target="vc"]'))
    chapters.Reverse()

end

function GetPages()
    
    local pdfDownloadUrl = GetPdfDownloadUrl(dom)

    if(not isempty(pdfDownloadUrl)) then

        -- The images are delivered as a PDF (with the ".jpg" file extension?).
        -- Some PDF chapters are paginated (#260).

        for page in Paginator.New(http, dom, '//a[contains(text(),"part") or input[contains(@value,">>>>")]]/@href') do
            pages.Add(GetPdfPageInfo(page))
        end

    else

        -- The images are delivered normally.
        
        for page in Paginator.New(http, dom, '//a[contains(text(),"หน้าถัดไป")]/@href') do

            pages.Add(page.SelectValue('//img/@src'))
    
        end

    end

end
