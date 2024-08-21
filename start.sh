#!/usr/bin/env bash

DEFAULT_VNC_PASSWORD="ArchTigerV837NC"

function _init_vnc_dir {
    if [[ ! -s "/root/.vnc/xstartup" ]]; then
        cp /vnc_defaults/xstartup /root/.vnc/xstartup
    fi
    if [[ ! -s "/root/.vnc/config" ]]; then
        cp vnc_defaults/config /root/.vnc/config
    fi
    chmod +x /root/.vnc/xstartup
}

# Add a custom xrandr resolution.
function addxrandr {
    local horiz
    local vert

    horiz=$(echo $1 | cut -d'x' -f1)
    vert=$(echo $1 | cut -d'x' -f2)

    local pixel_density
    pixel_density=$(echo "scale=10;($horiz * $vert * 60) / 1000000" | bc)

    xrandr --newmode $1 $pixel_density $horiz 0 0 $horiz $vert 0 0 $vert
    xrandr --addmode VNC-0 $1
}

# Read all the xrandr args (if they exist) from the environment and add them.
function _process_xrandr_env {
    while ! xhost >& /dev/null; do sleep .1s; done

    local resolutions
    resolutions=$CUSTOM_RESOLUTIONS
    if [[ ! -z "$CUSTOM_RESOLUTIONS" ]]; then
        IFS=',' ; for res in $resolutions; do
            echo "Adding $res resolution..."
            addxrandr $res
        done
    fi
}

function _set_password {
    local password
    local pwdfile
    pwdfile=/root/.vnc/passwd

    password=${VNC_PASSWORD:-$DEFAULT_VNC_PASSWORD}

    echo "$password" | vncpasswd -f > $pwdfile
    chmod 600 $pwdfile
}

# Start up the VNC server and do setup.
function _start_vnc {
    _init_vnc_dir
    _set_password

    _process_xrandr_env &

    vncserver :0 
}

_start_vnc
