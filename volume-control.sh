
TMP_FILE=/tmp/volume-control
VOLUME_INC=5


#set volume
VOLUME="$(pacmd list-sinks|grep -A 15 '* index'| awk '/volume: front/{ print $5 }' | sed 's/.$//' )";
ISMUTE="$(pacmd list-sinks|grep -A 15 '* index' |  awk '/muted:/{ print $2}')";

if [ "$1" = "inc" ]; then

	NEW_VOLUME=$(($VOLUME+$VOLUME_INC))
    if [ $VOLUME -lt 100 ] && [ $NEW_VOLUME -gt 100 ]; then
        NEW_VOLUME=100
    fi 
    pactl set-sink-volume @DEFAULT_SINK@ $NEW_VOLUME%
    
elif [ "$1" = "dec" ]; then

	NEW_VOLUME=$(($VOLUME-$VOLUME_INC))
    if [ $VOLUME -gt 100 ] && [ $NEW_VOLUME -lt 100 ]; then
        NEW_VOLUME=100
    fi
    pactl set-sink-volume @DEFAULT_SINK@ $NEW_VOLUME%
fi



if [ "$ISMUTE" = "yes" ]; then
    pactl set-sink-mute @DEFAULT_SINK@ 0;
elif [ "$1" = "mute" ]; then
    pactl set-sink-mute @DEFAULT_SINK@ 1;
fi



#set notify message and icon
VOLUME="$(pacmd list-sinks|grep -A 15 '* index'| awk '/volume: front/{ print $5 }' | sed 's/.$//' )";
ISMUTE="$(pacmd list-sinks|grep -A 15 '* index' |  awk '/muted:/{ print $2}')";


if [ "$VOLUME" -le 0 ] || [ "$ISMUTE" = "yes" ]; then
    ICON=audio-volume-muted
    COLOR=#6B6B6B
elif [ "$VOLUME" -le 20 ]; then
    ICON=audio-volume-low
    COLOR=#FFFFFF
elif [ "$VOLUME" -le 80 ]; then
    ICON=audio-volume-medium
    COLOR=#FFFFFF
else 
    ICON=audio-volume-high
    COLOR=#FFFFFF
fi

MESSAGE="$REPLACE_ID<span color='$COLOR' font='18px'>Volume: $VOLUME%</span>"



#get replace id from tmp file if exist
if [ -f "$TMP_FILE" ]; then
    REPLACE_ID="$(cat $TMP_FILE)"
fi

if [ -z "$REPLACE_ID" ]; then
    REPLACE_ID=0
fi


#create / replace notify 
ID=$(gdbus call --session \
             --dest org.freedesktop.Notifications \
             --object-path /org/freedesktop/Notifications \
             --method org.freedesktop.Notifications.Notify \
             "volume-control" "$REPLACE_ID" \
             "$ICON" " " "$MESSAGE" \
             [] {} 5000)

#save id to file
echo "$ID" | sed 's/(uint32 \([0-9]\+\),)/\1/' > "$TMP_FILE"
