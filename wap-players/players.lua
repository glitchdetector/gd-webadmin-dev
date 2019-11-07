local PAGE_NAME = "players"
local PAGE_TITLE = "Players"
local PAGE_ICON = "users"

function CreatePage(FAQ, data, add)
    add(FAQ.Table({"#", "Name", "Ping", "GUID"}, GetPlayers(), function(source)
        return {source, GetPlayerName(source), GetPlayerPing(source), GetPlayerGuid(source)}
    end))
    return true, "OK"
end

-- Automatically sets up a page and sidebar option based on the above configuration
Citizen.CreateThread(function()
    local FAQ = exports['webadmin-lua']:getFactory()
    exports['webadmin']:registerPluginOutlet("nav/sideList", function(data)
        if not exports['webadmin']:isInRole("webadmin."..PAGE_NAME..".view") then return "" end
        return FAQ.SidebarOption(PAGE_NAME, PAGE_ICON, PAGE_TITLE)
    end)
    exports['webadmin']:registerPluginPage(PAGE_NAME, function(data)
        if not exports['webadmin']:isInRole("webadmin."..PAGE_NAME..".view") then return "" end
        return FAQ.Nodes({
            FAQ.PageTitle(PAGE_TITLE),
            FAQ.BuildPage(CreatePage, data),
        })
    end)
end)
