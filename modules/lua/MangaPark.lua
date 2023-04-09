require "MangaParkV3"

local BaseGetInfo = GetInfo
local BaseGetChapters = GetChapters
local BaseGetPages = GetPages

function Register()

    module.Name = 'MangaPark'
    module.Language = 'English'

    module.Domains.Add('mangapark.net')
    module.Domains.Add('mangapark.org')

    -- Set the "set" cookie so that 18+ content is visible.

    global.SetCookie('.' .. module.Domains.First(), "set", "h=1")

end

function GetInfo()

    BaseGetInfo()

    if(not IsMangaParkV3()) then

        local json = Json.New(dom.SelectValue('//script[contains(@id,"__NEXT_DATA__")]'))
            .SelectToken('..state.data.data')

        info.Title = json.SelectValue('name')
        info.AlternativeTitle = json.SelectValues('altNames[*]')
        info.Author = json.SelectValues('authors[*]')
        info.Artist = json.SelectValues('artists[*]')
        info.Tags = json.SelectValues('genres[*]')
        info.Status = json.SelectValue('originalStatus')
        info.Summary = json.SelectValue('summary.code')
        info.Type = json.SelectValue('originalLanguage')

    end

end

function GetChapters()

    if(IsMangaParkV3()) then

        BaseGetChapters()

    else

        -- We have to query the API to get the chapter list.

        local comicId = GetComicId()
        local payload = '{"query":"\\n  query get_content_comicChapterRangeList($select: Content_ComicChapterRangeList_Select) {\\n    get_content_comicChapterRangeList(\\n      select: $select\\n    ) {\\n      reqRange{x y}\\n      missing\\n      pager {x y}\\n      items{\\n        serial \\n        chapterNodes {\\n          \\n  id\\n  data {\\n    \\n\\n  id\\n  sourceId\\n\\n  dbStatus\\n  isNormal\\n  isHidden\\n  isDeleted\\n  isFinal\\n  \\n  dateCreate\\n  datePublic\\n  dateModify\\n  lang\\n  volume\\n  serial\\n  dname\\n  title\\n  urlPath\\n\\n  srcTitle srcColor\\n\\n  count_images\\n\\n  stat_count_post_child\\n  stat_count_post_reply\\n  stat_count_views_login\\n  stat_count_views_guest\\n  \\n  userId\\n  userNode {\\n    \\n  id \\n  data {\\n    \\nid\\nname\\nuniq\\navatarUrl \\nurlPath\\n\\nverified\\ndeleted\\nbanned\\n\\ndateCreate\\ndateOnline\\n\\nstat_count_chapters_normal\\nstat_count_chapters_others\\n\\nis_adm is_mod is_vip is_upr\\n\\n  }\\n\\n  }\\n\\n  disqusId\\n\\n\\n  }\\n\\n          sser_read\\n        }\\n      }\\n\\n    }\\n  }\\n  ","variables":{"select":{"comicId":' .. comicId .. ',"range":null,"isAsc":false}},"operationName":"get_content_comicChapterRangeList"}'
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

end

function GetPages()

    if(IsMangaParkV3()) then

        BaseGetPages()

    else

        local json = Json.New(dom.SelectValue('//script[contains(@id,"__NEXT_DATA__")]'))
            .SelectToken('..imageSet')

        local fileNames = json.SelectValues('httpLis[*]')
        local accessTokens = json.SelectValues('wordLis[*]')

        for i = 0, fileNames.Count() - 1 do

            local imageUrl = fileNames[i] .. '?' .. accessTokens[i]

            pages.Add(imageUrl)

        end

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
