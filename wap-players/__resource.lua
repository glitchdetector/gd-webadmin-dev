name "Webadmin Player List Plugin"
author "glitchdetector"
contact "glitchdetector@gmail.com"
version "1.0"

description "A player list plugin for Webadmin"
details "It's a very simplified copy of the built-in player list, this is just an example, it serves no purpose."

dependency 'webadmin-lua'
webadmin_plugin 'yes'

server_script 'players.lua'
