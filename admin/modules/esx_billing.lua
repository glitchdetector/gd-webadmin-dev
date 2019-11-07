local BILLS_HISTORY = {}
local BILLS_LIMIT = 200
local BILLS_PER_PAGE = 20

RegisterServerEvent("esx_billing:sendBill")
AddEventHandler("esx_billing:sendBill", function(playerId, sharedAccountName, label, amount)
    local source = source
    table.insert(BILLS_HISTORY, 1, {source, GetPlayerName(source), playerId, GetPlayerName(playerId), label, amount, sharedAccountName, os.time()})
    while #BILLS_HISTORY > BILLS_LIMIT do
        table.remove(BILLS_HISTORY, #BILLS_HISTORY)
    end
end)

exports['webadmin']:registerPluginOutlet("nav/sideList", function(data)
    return FAQ.SidebarOption("esx-billing", "file-invoice-dollar", "ESX Billing History")
end)

exports['webadmin']:registerPluginPage("esx-billing", function(data)
    data = FAQ.PatchData(data)
    if not data.page then data.page = 1 end
    local page = tonumber(data.page)
    local firstMessage = BILLS_PER_PAGE * (page - 1) + 1
    local lastMessage = firstMessage + BILLS_PER_PAGE - 1

    local paginatorList = {}
    local paginatorPages = math.ceil(#BILLS_HISTORY / BILLS_PER_PAGE)
    if paginatorPages > 0 then
        if page > paginatorPages or page < 0 then page = 1 end
        table.insert(paginatorList, {"Previous", FAQ.GenerateDataUrl("esx-billing", {page = math.max(page - 1, 1)}), false, page == 1})
        for i = 1, paginatorPages do
            table.insert(paginatorList, {i, FAQ.GenerateDataUrl("esx-billing", {page = i}), i == page})
        end
        table.insert(paginatorList, {"Next", FAQ.GenerateDataUrl("esx-billing", {page = math.min(page + 1, paginatorPages)}), false, page == paginatorPages})
        local paginator = Pagination(paginatorList, "center")

        local chatlogData = {}
        for n = firstMessage, lastMessage do
            if n <= #BILLS_HISTORY and n > 0 then
                table.insert(chatlogData, {os.date("%X", BILLS_HISTORY[n][8]), BILLS_HISTORY[n][4], Nodes({
                    Node("span", {class = "text-muted"}, BILLS_HISTORY[n][7]),
                    " / ", BILLS_HISTORY[n][5], " ",
                    Badge("warning", "$" .. FAQ.ReadableNumber(BILLS_HISTORY[n][6], 2)),
                }), BILLS_HISTORY[n][2]})
            end
        end

        return Nodes({
            Breadcrumb({
                {"ESX", FAQ.GenerateDataUrl("esx", {})},
                {"Billing History"},
            }),
            FAQ.Table({"Timestamp", "Receiver", "Invoice", "Sender"}, chatlogData, false, "table-sm"),
            paginator,
        })
    else
        return BuildAlert("info", "No bills have been sent yet!")
    end
end)
