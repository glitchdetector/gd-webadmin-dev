exports['webadmin']:registerPluginOutlet("nav/sideList", function(data)
    return FAQ.SidebarOption("rrerr", "dragon", "Dragon Menu")
end)

exports['webadmin']:registerPluginPage("rrerr", function(data)
    return Node("img", {src = "https://puu.sh/EBvpQ.png", style = "width: 480px"}, "")
end)
