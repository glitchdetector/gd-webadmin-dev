FAQ = {}

FAQ.ReadableNumber = function(num, places)
    local ret
    local placeValue = ("%%.%df"):format(places or 0)
    if not num then
        return 0
    elseif num >= 1000000000000 then
        ret = placeValue:format(num / 1000000000000) .. "T" -- trillion
    elseif num >= 1000000000 then
        ret = placeValue:format(num / 1000000000) .. "B" -- billion
    elseif num >= 1000000 then
        ret = placeValue:format(num / 1000000) .. "M" -- million
    elseif num >= 1000 then
        ret = placeValue:format(num / 1000) .. "k" -- thousand
    else
        ret = placeValue:format(num) -- hundreds
    end
    return ret
end

-- Generate a paginator widget to navigate between pages
FAQ.GeneratePaginator = function(pageName, currentPage, maxPages)
    local paginatorList = {}
    if maxPages > 0 then
        if currentPage > maxPages or currentPage < 0 then currentPage = 1 end
        table.insert(paginatorList, {"Previous", FAQ.GenerateDataUrl(pageName, {page = math.max(currentPage - 1, 1)}), false, currentPage == 1})
        for i = 1, maxPages do
            table.insert(paginatorList, {i, FAQ.GenerateDataUrl(pageName, {page = i}), i == currentPage})
        end
        table.insert(paginatorList, {"Next", FAQ.GenerateDataUrl(pageName, {page = math.min(currentPage + 1, maxPages)}), false, currentPage == maxPages})
        return Pagination(paginatorList, "center")
    end
    return Pagination({
        {"Previous", "#", false, true},
        {"-", "#", true, true},
        {"Next", "#", false, true},
    }, "center")
end

-- Get the plugin url with extra parameters
FAQ.GenerateDataUrl = function(name, data)
    local url = exports["webadmin"]:getPluginUrl(name)
    for get, val in next, data do
        if get ~= 'name' then
            url = url .. ("&%s=%s"):format(get, val)
        end
    end
    return url
end

-- Show a button in the sidebar
-- page, string, name of page
-- icon, string, font awesome icon to represent page
-- name, string, title of page
-- badge, string, badge content (optional)
-- badgetype, string, badge type (optional, defaults to warning)
FAQ.SidebarOption = function(page, icon, name, badge, badgetype)
    return Node("li", {class = "nav-item"}, Node("a", {class = "nav-link", href = FAQ.GenerateDataUrl(page, {})}, {
        Node("i", {class = "nav-icon fa fa-" .. icon}, ""),
        " " .. name,
        badge and Badge(badgetype or "warning", badge) or "",
    }))
end

-- Simply turns a table of tables into a key value pair
-- Yes, it breaks if you have multiple of the same key, but who the fuck does that anyways?
FAQ.PatchData = function(data)
    local returnData = {}
    for k, v in next, data do
        returnData[k] = v[1]
    end
    return returnData
end

--[[
Arguments:
table headers*
    list of header titles
table data*
    list of rows, each row is a list of each column
function datafunc(rowdata, n)
    advanced function ran for every row, return formatted row data
string style
    extra table css style
string headstyle
    extra table head css style
]]
FAQ.Table = function(headers, data, datafunc, style, headstyle)
    local rows = {}
    if datafunc then
        for n, row in next, data do
            table.insert(rows, datafunc(row, n))
        end
    else
        rows = data
    end
    return TableBase({
        TableHead(headers, headstyle),
        TableBody(rows, true)
    }, style)
end

FAQ.PageTitle = function(title)
    return Node("h1", {}, title)
end

FAQ.InfoCard = function(title, data)
    local innerData = ""
    for _, entry in next, data do
        innerData = innerData .. Node("dt", {class = "col-sm-2"}, entry[1])
        innerData = innerData .. Node("dd", {class = "col-sm-10"}, entry[2])
    end
    innerData = Node("dl", {class = "row my-0"}, innerData)
    return CardBase({
        CardHeader(title),
        CardBody(innerData),
    })
end

FAQ.UserCard = function(title, subtitle, data)
    local innerData = ""
    for _, entry in next, data do
        innerData = innerData .. Callout(entry[1], entry[2], "primary", true)
    end
    return CardBase({
        CardHeader({TextIcon("user"), title}),
        CardBody({
            CardSubtitle(subtitle),
            innerData,
        }),
    })
end

local ALERT_ICON_TYPES = {
    ["warning"] = [[<i class="fa fa-exclamation-triangle"></i> ]],
    ["danger"] = [[<i class="fa fa-exclamation-circle"></i> ]],
    ["info"] = [[<i class="fa fa-info-circle"></i> ]],
}
FAQ.Alert = function(alert, message, important, no_icon)
    return [[<div class="alert alert-]]..alert..[[" role="alert">]]..(important and "<strong>" or "")..(no_icon and "" or (ALERT_ICON_TYPES[alert] or ""))..message..(important and "</strong>" or "")..[[</div>]]
end
