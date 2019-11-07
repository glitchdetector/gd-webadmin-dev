exports['webadmin']:registerPluginOutlet("nav/sideList", function(data)
    return FAQ.SidebarOption("playerlist", "users", "Player List", #GetPlayers() .. " / " .. GetConvar("sv_maxclients", 32), "secondary")
end)
exports['webadmin']:registerPluginPage("playerlist", function(data)
    return Nodes({
        FAQ.PageTitle({"Player List", " ", Badge("info", #GetPlayers() .. " / " .. GetConvar("sv_maxclients", 32))}),
        FAQ.Table({"ID", "Name", "GUID"}, GetPlayers(), function(source) return {source, GetPlayerName(source), GetPlayerGuid(source)} end),
    })
end)
