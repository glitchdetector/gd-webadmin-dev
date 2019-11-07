exports['webadmin']:registerPluginOutlet("nav/sideList", function(data)
    return FAQ.SidebarOption("esx-whitelist", "door-open", "ESX Whitelist")
end)

exports['webadmin']:registerPluginPage("esx-whitelist", function(data)
    data = FAQ.PatchData(data)
    if data.action then
        if data.action == "whitelist" then
            if data.id then
                local identifier = data.id
                ExecuteCommand("wladd " .. identifier)
                return FAQ.Alert("success", "Added the identifier <strong>steam:" .. identifier .. "</strong> to the whitelist!")
            end
        elseif data.action == "blacklist" then
            if data.id then

            end
        end
        return FAQ.Alert("warning", "Malformed action")
    end
    return Nodes({
        Breadcrumb({
            {"ESX", FAQ.GenerateDataUrl("esx", {})},
            {"Whitelist"},
        }),
        CardBase({
            CardHeader("Whitelist User"),
            CardBody(Form("esx-whitelist", {action = "whitelist"}, {
                FormInputTextGroup("id", "1100001037e7ceb", "steam:"),
                GenerateFormSubmitButton("Add to whitelist", "success"),
            })),
        })
    })
end)
