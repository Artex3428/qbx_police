fx_version 'cerulean'
game 'gta5'

name 'qbx_policejob'
description 'Police system for Qbox'
repository 'https://github.com/Qbox-project/qbx_policejob'
version '1.0.0'

ox_lib 'locale'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua'
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

dependencies {
    "ox_target",
    "ox_inventory",
    "ox_lib"
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/vue.min.js',
    'html/script.js',
    'html/fingerprint.png',
    'html/main.css',
    'config/client.lua',
    'config/shared.lua',
    'locales/*.json',
    "audiodata/nd_police.dat54.rel",
    "audiodirectory/nd_police.awc"
}

data_file "DLC_ITYP_REQUEST" "stream/cuffs_main.ytyp"
data_file "AUDIO_WAVEPACK" "audiodirectory"
data_file "AUDIO_SOUNDDATA" "audiodata/nd_police.dat"

lua54 'yes'
use_experimental_fxv2_oal 'yes'