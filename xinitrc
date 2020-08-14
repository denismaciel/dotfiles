!# /bin/sh
/home/$USER/Applications/dwm-bar/dwm_bar.sh & 
bluetoothctl power on

picom -b --config /home/$USER/config/picom/picom.conf &

eval $(ssh-agent)

HOSTNAME=$(hostname)

if [ $HOSTNAME == "MacbookPro" ]; then 
    echo "Setting Layout for a Mac keyboard"
    setxkbmap -option # Reset
    setxkbmap -option altwin:swap_alt_win
fi

echo "Setting general keyboard options"
setxkbmap -layout us -option ctrl:nocaps
xset r rate 200 80

# relaunch DWM if the binary changes, otherwise bail
csum=$(sha1sum $(which dwm))
new_csum=""
while true
do
    if [ "$csum" != "$new_csum" ]
    then
        csum=$new_csum
        dwm
    else
        exit 0
    fi
    new_csum=$(sha1sum $(which dwm))
    sleep 0.5
done
