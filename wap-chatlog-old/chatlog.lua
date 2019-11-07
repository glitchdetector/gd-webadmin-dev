-- Chat History Webadmin plugin
-- by glitchdetector, Nov. 2019
-- Made as an example for the Webadmin plugin system
-- Heavily commented for the sake of introduction
-- FAQ is the widget factory, it contains helper functions to make cool widgets
Citizen.CreateThread(function()
    local FAQ = exports['webadmin-lua']:getFactory()

    -- Maximum amount of stored chat messages (-1 for unlimited!)
    local CHATLOG_LIMIT = GetConvarInt("chatlog_limit", 200)
    -- Maximum amount of entries on one page
    local CHATLOG_PER_PAGE = GetConvarInt("chatlog_per_page", 25)
    -- Show the unread messages notification
    local CHATLOG_SHOW_UNREAD_MESSAGES = GetConvar("chatlog_show_unread_messages", "true") == "true"

    -- Page details
    local PAGE_NAME = "chatlog"
    local PAGE_TITLE = "Chat History"
    local PAGE_ICON = "comments"

    -- Required ACE permission to view the page
    local PERMISSION = "webadmin.chatlog.view"

    -- Table to contain all stored chat messages
    local CHATLOG_HISTORY = {}
    -- Tally to count amount of sent messages
    local CHATLOG_TALLY = 0
    local CHATLOG_LAST_TALLY = 0

    -- Pre-make the timestamp header
    local TIMESTAMP_HEADER = FAQ.Node("div", {class = "text-center"}, FAQ.Icon("clock"))

    -- Fetch incoming chat messages
    AddEventHandler("chatMessage", function(source, author, message)
        -- Add to tally
        CHATLOG_TALLY = CHATLOG_TALLY + 1
        -- Store the message details
        table.insert(CHATLOG_HISTORY, 1, {source, author, message, os.time()})
        -- Update convar value before we use it
        CHATLOG_LIMIT = GetConvarInt("chatlog_limit", 200)
        -- Delete excess messages (if we have more than the limit)
        while ((CHATLOG_LIMIT > 0) and (#CHATLOG_HISTORY > CHATLOG_LIMIT)) do
            table.remove(CHATLOG_HISTORY, #CHATLOG_HISTORY)
        end
    end)

    -- Create the side bar button to access the page
    exports['webadmin']:registerPluginOutlet("nav/sideList", function(data)
        -- Make sure the user has the required permission!
        if not exports['webadmin']:isInRole(PERMISSION) then return "" end
        -- Update convar value before we use it
        CHATLOG_SHOW_UNREAD_MESSAGES = GetConvar("chatlog_show_unread_messages", "true") == "true"
        -- Generate the sidebar button (using the custom widget factory)
        return FAQ.SidebarOption(PAGE_NAME, PAGE_ICON, PAGE_TITLE, (CHATLOG_SHOW_UNREAD_MESSAGES and CHATLOG_TALLY > CHATLOG_LAST_TALLY) and (CHATLOG_TALLY - CHATLOG_LAST_TALLY) or false)
    end)

    -- Handle the page itself
    exports['webadmin']:registerPluginPage(PAGE_NAME, function(data)
        -- Make sure the user has the required permission!
        if not exports['webadmin']:isInRole(PERMISSION) then return "" end
        -- Patch the data by simplifying the structure (check factory code for more info on this)
        data = FAQ.PatchData(data)
        -- Update convar value before we use it
        CHATLOG_PER_PAGE = GetConvarInt("chatlog_per_page", 25)
        -- Calculate the amount of pages
        local paginatorPages = math.ceil(#CHATLOG_HISTORY / CHATLOG_PER_PAGE)
        -- Since we want to use pagination, make sure there's a page value
        if not data.page then data.page = 1 end
        local page = math.max(0, math.min(paginatorPages, tonumber(data.page)))
        -- Generate the paginator
        local paginator = FAQ.GeneratePaginator(PAGE_NAME, page, paginatorPages)
        -- Calculate the shown message range
        local firstMessage = CHATLOG_PER_PAGE * (page - 1) + 1
        local lastMessage = firstMessage + CHATLOG_PER_PAGE - 1
        -- Generate the shown message history list
        local chatlogData = {}
        for n = firstMessage, lastMessage do
            if n <= #CHATLOG_HISTORY and n > 0 then
                -- Table Factory takes raw row data directly by default, so we pre-format the data here
                table.insert(chatlogData, {os.date("%X", CHATLOG_HISTORY[n][4]), CHATLOG_HISTORY[n][2], CHATLOG_HISTORY[n][3]})
            end
        end
        -- Update that the chatlog has been viewed
        CHATLOG_LAST_TALLY = CHATLOG_TALLY
        -- Generate the final page (Nodes allows us to add multiple widgets together)
        return FAQ.Nodes({
            -- Page title with a badge showing the tally
            FAQ.PageTitle({PAGE_TITLE, " ", FAQ.Badge("info", CHATLOG_TALLY)}),
            (paginatorPages > 0) and (
                -- Show the message history table (if there are any)
                FAQ.Table({TIMESTAMP_HEADER, "Name", "Message"}, chatlogData, false, "table-sm")
            ) or (
                -- Show an alert (if there are no messages to display)
                FAQ.Alert("info", "No chat messages have been sent yet!")
            ),
            paginator, -- The paginator at the bottom
        })
    end)
end)
