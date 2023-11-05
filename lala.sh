#!/bin/bash

AUDIO_FILE=$1
GIF_PFP="";PFP=pfp.jpg
#GIF_PFP="-stream_loop -1";PFP=3ds.gif
RES=2
PFP_SIZE=$((200*$RES))
TEXT_SIZE=$((20*$RES))
VIDEO_WIDTH=$((640*$RES))
VIDEO_HEIGHT=$((360*$RES))
AUDIO_SECS=$(ffprobe -i $1 -show_entries format=duration -v quiet -of csv="p=0")
#COLOR="#ff80b3"
COLOR="#F91880"
TEXT_COLOR="#ffffff80"
DIS_FROM_BOT=40
ffmpeg -hwaccel vaapi -hwaccel_output_format vaapi -hwaccel_device /dev/dri/renderD128 \
  -y -i $AUDIO_FILE \
  -f lavfi -i color=c=$COLOR:s=$VIDEO_WIDTH"x"$VIDEO_HEIGHT \
  $GIF_PFP -i $PFP -i circle.png \
  -i speaker.png \
  -filter_complex \
    "[2:v]scale=$PFP_SIZE:$PFP_SIZE[profile];\
    [3:v]scale=$PFP_SIZE:$PFP_SIZE[alpha_mask];\
    [profile][alpha_mask]alphamerge[masked_profile];\
    [1]drawtext=text='⬤':fontfile=symbols.ttf:x=(W-text_w)/2:y=(H-text_h)/2:fontsize=$PFP_SIZE+(sin(t*10)*35)*$RES:fontcolor=#ffffff60[bg];\
    [bg]drawtext=text='⬤':fontfile=symbols.ttf:x=(W-text_w)/2:y=(H-text_h)/2:fontsize=$PFP_SIZE+(sin((t+20)*10)*35)*$RES:fontcolor=#ffffff60[bg];\
    [bg][masked_profile]overlay=x=(W-w)/2:y=(H-h)/2[bg];\
    [bg]drawtext=text='%{eif\:floor(($AUDIO_SECS-t)/60)\:d\:1}\:%{eif\:mod(($AUDIO_SECS-t)\,60)\:d\:2}'\
    :fontfile=Chirp-Regular.woff2:x=20*$RES:y=H-$DIS_FROM_BOT*$RES:fontsize=$TEXT_SIZE:fontcolor=$TEXT_COLOR[bg];\
    [4:v]scale=$TEXT_SIZE+(2*$RES):$TEXT_SIZE+(2*$RES)[speaker];\
    [bg][speaker]overlay=x=73*$RES:y=H-($DIS_FROM_BOT+4)*$RES[bg];\
    [bg]drawtext=text='Voice':fontfile=Chirp-Bold.woff2:x=(W-text_w)-20*$RES:y=H-$DIS_FROM_BOT*$RES:fontsize=$TEXT_SIZE:fontcolor=$TEXT_COLOR;"\
  -c:v libx264 -c:a aac -strict experimental -t $AUDIO_SECS output.mp4
