local Proxy = module("vrp", "lib/Proxy")
local Tunnel = module("vrp", "lib/Tunnel")

MySQL = module("vrp_mysql", "MySQL")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","webadmin")

function GenerateDataUrl(name, data)
    local url = exports["webadmin"]:getPluginUrl(name)
    for get, val in next, data do
        if get ~= 'name' then
            url = url .. ("&%s=%s"):format(get, val)
        end
    end
    return url
end

function GenerateForm(target, values, contents)
    local url = exports["webadmin"]:getPluginUrl(target)
    local html = [[<form method="get" style="display: inline-block;" action="]]..url..[[">]]
    html = html .. [[<input type="hidden" name="name" value="]]..target..[[">]]
    for k, v in next, values do
        html = html .. [[<input type="hidden" name="]]..k..[[" value="]]..v..[[">]]
    end
    for _, v in next, contents do
        html = html .. v
    end
    html = html .. [[</form>]]
    return html
end

function PatchData(data)
    local returnData = {}
    for k, v in next, data do
        returnData[k] = v[1]
    end
    return returnData
end

exports['webadmin']:registerPluginPage("cunt", function(data)
    return GenerateForm("data", {user_id = 3}, {
        GenerateFormSlider("money", 0, 200, 100),
        GenerateFormSubmitButton("Give Money", "success", "user_id", 3),
        Callout("Name", "glitchdetector", "success", true)
    })
end)

function GenerateFormSlider(name, min, max, default)
    return [[<input type="range" class="custom-range" name="]]..name..[[" min="]]..min..[[" max="]]..max..[[" value="]]..default..[["></input>]]
end
function GenerateFormInput(name, min, max, default)
    return [[<input type="range" name="]]..name..[[" min="]]..min..[[" max="]]..max..[[" value="]]..default..[["></input>]]
end

function GenerateFormSubmitButton(text, style, name, value)
    return [[<button type="submit"]]..(name and ' name="'..name..'"' or "")..(value and ' value="'..value..'"' or "")..[[class="btn btn-]]..(style or "")..[[">]]..text..[[</button>]]
end

exports['webadmin']:registerPluginPage("userlist", function(data)
    data = PatchData(data)
    if exports['webadmin']:isInRole('webadmin.view.players') then
        local users = {}
        if data.group then
            users = vRP.getUsersByGroup({data.group})
        else
            local _users = vRP.getUsers({})
            for user_id, _ in next, _users do
                table.insert(users, user_id)
            end
        end
        return BuildTable({"User ID", "Username", "Current Job", "Actions"}, users, function(user_id)
            local source = vRP.getUserSource({user_id})
            return {
                ("<strong>%s</strong>"):format(user_id),
                GetPlayerName(source),
                vRP.getJobName({vRP.getUserGroupByType({user_id, "job"})}),
                BuildUserActionBar(data, source),
            }
        end, "", "")
    end
    return "!"
end)

exports['webadmin']:registerPluginPage("demo-adv", function(data)
    return BuildTable({"Name", "User ID"}, {
        {name = "Person", id = 7484},
        {name = "Pear", id = 32453},
        {name = "Glitch", id = 621, staff = true},
        {name = "Pineapple", id = 4224},
    }, function(data)
        local r = {}
        r[1] = data.name
        if data.staff then r[1] = r[1] .. " <div class='badge badge-warning'><i class='fa fa-star'></i> Staff</div>" end
        r[2] = data.id
        return r
    end, "table-sm table-responsive-sm mb-0", "")
end)

exports['webadmin']:registerPluginPage("demo-jobs", function(data)
    return FAQ.Table(
        {"Job", "Online Players"},
        vRP.getGroupsByType({"job"}),
        function(data, n)
            local r = {}
            r[1] = vRP.getJobName({data})
            r[2] = n
            return r
        end,
        "table-sm table-responsive-sm mb-0",
        "dark"
    )
end)

exports['webadmin']:registerPluginPage("demo", function(data)
    return Nodes({
        Navbar("Sample Navbar", {
            NavbarNav({
                NavLink("FiveM", "#"),
                NavLink("Transport Tycoon", "#"),
                NavLink("Staff Panel", "#"),
            }),
            NavbarText("rrerr")
        }),
        Table({"Name", "User ID"}, {
            {"Person", 7484},
            {"Pear", 32453},
            {"Glitch", 621},
            {"Pineapple", 4224},
        }),
        TableSmall({"Name", "User ID"}, {
            {"Person", 7484},
            {"Pear", 32453},
            {"Glitch", 621},
            {"Pineapple", 4224},
        }),
        Switch("switch1"),
        Switch("switch2", true),
        Switch("switch3", false),
        Pagination({
            {"Previous", "#"},
            {"1", "#", true},
            {"2", "#"},
            {"3", "#"},
            {"Next", "#"},
        }, "center"),
        ProgressBar(0, 100, 50, "Progress", "warning"),
        ProgressGroup(0, 100, 84, {
            TextIcon("globe"),
            "Quest Progress",
        }, "84 / 100", "success"),
        Alert("warning", {
            AlertHeading({
                TextIcon("exclamation-triangle"),
                "Oh no!"
            }),
            "This reminds me of Flutter",
        }, true),
        Callout("Title", "Sample Text", "warning", true),
        Breadcrumb({
            {"FiveM", "#"},
            {"Transport Tycoon", "#"},
            {"Staff Panel"},
        }),
        Form("data", {user_id = 3}, {
            GenerateFormSlider("money", 0, 200, 100),
            GenerateFormSubmitButton("Give Money", "success", "user_id", 3),
            Callout("Name", "glitchdetector", "success", true)
        }),
        Card("glitchdetector", "Trucker (Commercial)", CardText("This is your profile card"), {
            CardLink("Cheats", "#"),
            CardLink("Delete Account", "#")
        }),
        Dropdown("Dropdown Test", {
            {"FiveM", "#"},
            {"Transport Tycoon", "#"},
            {"Staff Panel", "#"},
        }),
        DropdownButton("primary", "Dropdown Test", "#", {
            {"FiveM", "#"},
            {"Transport Tycoon", "#"},
            {"Staff Panel", "#"},
        }),
        Footer("Hello", "World"),
        Card("Sign up", "", Form("sign-up", {}, {
            FormInputText("username", "John Doe", "Username"),
            FormInputPassword("password", "", "Password"),
            FormInputCheckbox("signup", false, "I have read the EULA"),
            ButtonGroup({
                FormInputRadio("gender", "male", true, "Male", true),
                FormInputRadio("gender", "female", false, "Female", true),
                FormInputRadio("gender", "other", false, "Other", true),
            }),
            Node("br"),
            FormInputTextGroup("donation", "Donation", "$", ".00 USD"),
            GenerateFormSubmitButton("Sign up", "primary"),
        }), "Footer!"),
    })
end)


exports['webadmin']:registerPluginPage("data", function(data)
    print(json.encode(data))
    return json.encode(data)
end)
exports['webadmin']:registerPluginPage("kek", function(data)
    return json.encode(data)
end)

exports['webadmin']:registerPluginPage("userinfo", function(data)
    data = PatchData(data)
    if data.source then
        local source = data.source
        local user_id = vRP.getUserId({source})
        if user_id then
            local bank = vRP.getBankMoney({user_id})
            local money = vRP.getMoney({user_id})
            return FAQ.UserCard(GetPlayerName(source), "Account information", {
                {"Wallet", "$" .. ReadableNumber(money, 2)},
                {"Bank", "$" .. ReadableNumber(bank, 2)},
            })
        end
    end
    return BuildAlert("warning", "An error occured while processing", true)
end)

exports['webadmin']:registerPluginPage("joblist", function(data)
    data = PatchData(data)
    if exports['webadmin']:isInRole('webadmin.view.jobs') then
        local jobs = vRP.getGroupsByType({"job", true})
        for _, job in next, jobs do
            job[3] = #vRP.getUsersByGroup({job[1]})
        end
        table.sort(jobs, function(a,b)
            return a[1] < b[1]
        end)
        table.sort(jobs, function(a,b)
            return a[3] > b[3]
        end)
        return BuildTable({"Job Name"}, jobs, function(job)
            if job[3] > 0 then
                return {
                    "<strong><a role='button' href='"..GenerateDataUrl("userlist", {group = job[1]}).."'>" .. vRP.getJobName({job[1]}) .. "</a> <span class='badge badge-" .. (job[3] > 0 and "primary" or "secondary") .. "'>" .. job[3] .. "</span></strong>"
                }
            else
                return false
            end
        end)
    end
    return "!"
end)

exports['webadmin']:registerPluginPage("map", function(data)
    return LoadResourceFile("admin", "files/map.html")
end)

exports['webadmin']:registerPluginPage("action", function(data)
    local success = false
    local details = "You do not have permission to do this"
    if success then
        return BuildAlert("success", details)
    else
        return BuildAlert("danger", details, true)
    end
end)

exports['webadmin']:registerPluginPage("gd-test", function(data)
    return BuildBody()
end)

exports['webadmin']:registerPluginOutlet("nav/sideList", function(data)
    if exports['webadmin']:isInRole('command.clientkick') then
        return [[<li class="nav-item">
            <a class="nav-link" href="]]..exports["webadmin"]:getPluginUrl("gd-test")..[[">
                <i class="nav-icon fa fa-id-badge"></i> Staff Panel
            </a>
            <a class="nav-link" href="]]..GenerateDataUrl("joblist", {})..[[">
                <i class="nav-icon fa fa-toolbox"></i> Job List
            </a>
            <a class="nav-link" href="]]..GenerateDataUrl("userlist", {})..[[">
                <i class="nav-icon fa fa-users"></i> User List
            </a>
            <a class="nav-link" href="]]..GenerateDataUrl("map", {})..[[">
                <i class="nav-icon fa fa-map-marked-alt"></i> Map
            </a>
        </li>]]
    else
        return ""
    end
end)

exports['webadmin']:registerPluginOutlet("home/dashboardTop", function(data)
    return BuildStatsPreview(data)
end)

function BuildStatsPreview(data)
    if exports['webadmin']:isInRole('webadmin.view') then
        return [[
    <div class="row">
        <div class="col-md-12">
            <div class="alert alert-danger" role="alert">
                <strong><i class="fa fa-exclamation-triangle"></i> No database connection</strong>
            </div>
            <div class="alert alert-warning" role="alert">
                <h4 class="alert-heading">Server is preparing to restart</h4>
                <p>Server has lost connection to the database</p>
            </div>
        </div>
    </div>
        ]]
    else
        return [[
    <div class="row">
        <div class="col-md-12">
            <div class="alert alert-warning" role="alert">
                <strong>You are not logged into an authorized account.</strong>
            </div>
        </div>
    </div>
        ]]
    end
end

local ALERT_ICON_TYPES = {
    ["warning"] = [[<i class="fa fa-exclamation-triangle"></i> ]],
    ["danger"] = [[<i class="fa fa-exclamation-circle"></i> ]],
    ["info"] = [[<i class="fa fa-info-circle"></i> ]],
}
function BuildAlert(alert, message, important, no_icon)
    return [[<div class="alert alert-]]..alert..[[" role="alert">]]..(important and "<strong>" or "")..(no_icon and "" or (ALERT_ICON_TYPES[alert] or ""))..message..(important and "</strong>" or "")..[[</div>]]
end

exports['webadmin']:registerPluginOutlet("nav/topList", function(data)
    local ok, state = vRP.getServerState({})
    if not ok then
        return [[<li class="nav-item px-3"><strong>Status: <span class='badge badge-warning'><i class='fa fa-exclamation-triangle'></i> ]]..state..[[</span></strong></li>]]
    else
        return [[<li class="nav-item px-3"><strong>Status: <span class='badge badge-success'>]]..state..[[</span></strong></li>]]
    end
end)

exports['webadmin']:registerPluginOutlet("nav/topList", function(data)
    return [[<li class="nav-item px-3"><strong>Uptime: <span class='badge'>]]..GetConvar("uptime", "00h 00m")..[[</span></strong></li>]]
end)

exports['webadmin']:registerPluginOutlet("nav/topList", function(data)
    return [[<li class="nav-item px-3"><strong>Server: <span class='badge'>]]..GetConvar("chatlog_prefix", "EU0")..[[</span></strong></li>]]
end)

function BuildBody(data)
    local html = [[

    ]]..BuildUserList(data)..[[

    ]]..BuildFooter(data)..[[

    ]]
    return html
end

function BuildHeader(data)
    local html = [[]]
    html = html .. "Online Users"
    return html
end

function BuildSideMenu(data)
    local html = [[]]
    html = html .. "Side Bar"
    return html
end

local ONLINE_USERS = {
    {1, "glitchdetector", "DATA1", "DATA2", "DATA3"},
    {2, "Collins", "DATA1", "DATA2", "DATA3"},
    {3, "ArchitectCobra", "DATA1", "DATA2", "DATA3"},
    {4, "Morfik", "DATA1", "DATA2", "DATA3"},
    {5, "Stormm", "DATA1", "DATA2", "DATA3"},
    {6, "Mek", "DATA1", "DATA2", "DATA3"},
    {7, "TheCaptain", "DATA1", "DATA2", "DATA3"},
    {8, "Zabivaka", "DATA1", "DATA2", "DATA3"},
}

function BuildTable(headers, rows, func, tablecss, theadcss)
    local html = [[]]
    tablecss = "table table-striped " .. (tablecss or "")
    theadcss = "thead-dark " .. (theadcss or "")
    html = html .. [[
<table class="]]..tablecss..[[">
    <thead class="]]..theadcss..[[">
        <tr>]]
    for _, header in next, headers do
        html = html .. [[<th scope="col">]]..header..[[</th>]]
    end
    html = html .. [[
        </tr>
    </thead>
    <tbody>]]
    for _, row in next, rows do
        local data = row
        if func then
            data = func(row)
        end
        if data then
            html = html .. BuildTableRow(data)
        end
    end
    html = html .. [[
    </tbody>
</table>
]]
    return html
end

function BuildTableRow(row)
    local html = [[<tr>]]
    for _, text in next, row do
        html = html .. [[<td>]]..text..[[</td>]]
    end
    html = html .. [[</tr>]]
    return html
end

function BuildUserList(data)
    local html = [[]]
    html = html .. [[
<table class="table">
    <thead>
        <tr>
            <th scope="col">User ID</th>
            <th scope="col">Username</th>
            <th scope="col">Data</th>
            <th scope="col">Actions</th>
        </tr>
    </thead>
    <tbody>]]
    for _, user in next, ONLINE_USERS do
        html = html .. BuildUserEntry(data, user)
    end
    html = html .. [[
    </tbody>
</table>
]]
    return html
end

function BuildUserListFromUserIds(data, users)
    local html = [[]]
    html = html .. [[
<table class="table">
    <thead>
        <tr>
            <th scope="col">User ID</th>
            <th scope="col">Username</th>
            <th scope="col">Data</th>
            <th scope="col">Actions</th>
        </tr>
    </thead>
    <tbody>]]
    for _, user in next, users do
        html = html .. BuildUserEntryFromUserId(data, user)
    end
    html = html .. [[
    </tbody>
</table>
]]
    return html
end

function BuildUserEntryFromUserId(data, user_id)
    local source = vRP.getUserSource({user_id})
    local name = GetPlayerName(source)
    local html = [[]]
    html = html .. [[
<tr>
    <th scope="row">]]..user_id..[[</th>
    <td>]]..name..[[</td>
    <td></td>
    <td>]]..BuildUserActionBar(data, source)..[[</td>
</tr>
]]
    print(source, name)
    return html
end

function BuildUserEntry(data, user)
    local html = [[]]
    html = html .. [[
<tr>
    <th scope="row">]]..user[1]..[[</th>
    <td>]]..user[2]..[[</td>
    <td>]]..json.encode({user[3],user[4],user[5]})..[[</td>
    <td>]]..BuildUserActionBar(data, user[1])..[[</td>
</tr>
]]
    return html
end

function BuildUserActionBar(data, user)
    local html = BuildUserInfoButton(data, user)
    return html
end

function BuildUserKickButton(data, user)
    return ""
    -- return [[<button type="button" class="btn btn-lg btn-block btn-warning">Kick</button>]]
end
function BuildUserInfoButton(data, user)
    return [[<a role="button" class="btn btn-primary btn-sm btn-block" href="]]..GenerateDataUrl("userinfo", {source = user})..[[">Info</a>]]
end

function BuildFooter(data)
    local html = [[]]
    html = html .. "Footer (c) glitchdetector 2019 - 621"
    return html
end
