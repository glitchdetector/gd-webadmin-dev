name "Webadmin Plugin"
author "glitchdetector"
contact "glitchdetector@gmail.com"
version "1.0"

description "A plugin for Webadmin"
details [[
    Adds a new page to Webadmin
]]
usage [[
    Go to Webadmin
    Log in
    Select the plugin page
]]

dependency 'webadmin'

server_script '@vrp/lib/utils.lua'

server_script 'utils/*.lua'
--server_script 'modules/*.lua'
server_script 'modules/playerlist.lua'
server_script 'modules/chatlog.lua'
