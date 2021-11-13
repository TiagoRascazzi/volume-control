#!/bin/sh

mpv ~/script/volume-control/Blop-Mark_DiAngelo-79054334.mp3 >/dev/null &


TMP_FILE=/tmp/volume-control
TMP_FILE_DATE=/tmp/volume-control-date
VOLUME_INC=5
DELAY=1000

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
elif [ "$VOLUME" -le 20 ]; then
    ICON=audio-volume-low
elif [ "$VOLUME" -le 80 ]; then
    ICON=audio-volume-medium
elif [ "$VOLUME" -le 100 ];  then
    ICON=audio-volume-high
else 
    ICON=audio-ready
fi

MESSAGE="Volume: $VOLUME%"


#get replace id from tmp file if existi
PREV_DATE=$(cat $TMP_FILE_DATE)
CURR_DATE=$(date +%s%3N)
END_DATE=$(($PREV_DATE+$DELAY))

OLD_ID=$(cat $TMP_FILE)

if [ -f "$TMP_FILE" ] && [ ! -z $OLD_ID ] && [ $CURR_DATE -lt $END_DATE ]; then
    ID=$(desktop-notify "$MESSAGE" --icon $ICON --timeout $DELAY --id $OLD_ID)
    if [ -z $ID ]; then
        echo ERRRORROROROR
	ID=$OLD_ID
    fi
else
    ID=$(desktop-notify "$MESSAGE" --icon $ICON --timeout $DELAY)
fi

#save id and date to file
echo $CURR_DATE > "${TMP_FILE_DATE}"
echo "$ID" | sed 's/(uint32 \([0-9]\+\),)/\1/' > "$TMP_FILE"
