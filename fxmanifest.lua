fx_version 'cerulean'
game 'gta5'

author 'YourName'
description 'Fart effect with sound, camera shake, and proximity-based effects.'
version '1.0.0'

-- Client and server scripts
client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

-- Streamed custom assets
files {
    'stream/fart.ogg',
    'stream/index.html'
}

-- Define the NUI page
ui_page 'stream/index.html'
