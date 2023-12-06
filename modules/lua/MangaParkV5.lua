function GetInfo()

    info.Title = dom.SelectValue('//div[contains(@class,"md:block")]//h3')
    info.Summary = dom.SelectValue('//div[contains(@class,"limit-html-p")]')
    info.AlternativeTitle = dom.SelectValues('//div[contains(@class,"md:block")]//h3/following-sibling::div//span[not(@class)]')
    info.Author = dom.SelectValues('//div[contains(@class,"md:block")]//h3/following-sibling::div[2]//a')
    info.Tags = dom.SelectValues('//b[contains(text(),"Genres:")]/following-sibling::span//span[not(contains(text(),","))]')
    info.Status = dom.SelectValue('//span[contains(text(),"Original Publication")]/following-sibling::span')

end

function GetChapters()

    -- We have to query the API to get the chapter list.

    local comicId = GetComicId()
    local payload =
        '{"query":"\\n  query get_content_comicChapterRangeList($select: Content_ComicChapterRangeList_Select) {\\n    get_content_comicChapterRangeList(\\n      select: $select\\n    ) {\\n      reqRange{x y}\\n      missing\\n      pager {x y}\\n      items{\\n        serial \\n        chapterNodes {\\n          \\n  id\\n  data {\\n    \\n\\n  id\\n  sourceId\\n\\n  dbStatus\\n  isNormal\\n  isHidden\\n  isDeleted\\n  isFinal\\n  \\n  dateCreate\\n  datePublic\\n  dateModify\\n  lang\\n  volume\\n  serial\\n  dname\\n  title\\n  urlPath\\n\\n  srcTitle srcColor\\n\\n  count_images\\n\\n  stat_count_post_child\\n  stat_count_post_reply\\n  stat_count_views_login\\n  stat_count_views_guest\\n  \\n  userId\\n  userNode {\\n    \\n  id \\n  data {\\n    \\nid\\nname\\nuniq\\navatarUrl \\nurlPath\\n\\nverified\\ndeleted\\nbanned\\n\\ndateCreate\\ndateOnline\\n\\nstat_count_chapters_normal\\nstat_count_chapters_others\\n\\nis_adm is_mod is_vip is_upr\\n\\n  }\\n\\n  }\\n\\n  disqusId\\n\\n\\n  }\\n\\n          sser_read\\n        }\\n      }\\n\\n    }\\n  }\\n  ","variables":{"select":{"comicId":' ..
        comicId .. ',"range":null,"isAsc":false}},"operationName":"get_content_comicChapterRangeList"}'
    local chaptersJson = GetApiJson(payload)

    for chapterNode in chaptersJson.SelectTokens('..chapterNodes[*].data') do

        local chapterInfo = ChapterInfo.New()

        chapterInfo.Volume = chapterNode.SelectValue('volume')
        chapterInfo.Title = chapterNode.SelectValue('dname')
        chapterInfo.Url = chapterNode.SelectValue('urlPath')
        chapterInfo.Version = chapterNode.SelectValue('srcTitle')
        chapterInfo.Language = chapterNode.SelectValue('lang')

        chapters.Add(chapterInfo)

    end

    chapters.Reverse()

end

function GetPages()

    -- Extract image URLs from the JSON at the bottom of the page.

    local imagesScript = dom.SelectValue('//script[contains(@type,"qwik/json")]')

    for imageUrl in imagesScript:regexmany('"(https:\\/\\/[^"]+&exp=[^"]+)', 1) do
        pages.Add(imageUrl)
    end

end

function IsMangaParkV3()
    return url:contains('/comic/')
end

function GetComicId()
    return url:regex('\\/(?:title|comic)\\/(\\d+)', 1)
end

function GetApiUrl()
    return '/apo/'
end

function GetApiJson(postDataStr)

    http.Headers['accept'] = '*/*'
    http.Headers['content-type'] = 'application/json'

    return Json.New(http.Post(GetApiUrl(), postDataStr))

end
