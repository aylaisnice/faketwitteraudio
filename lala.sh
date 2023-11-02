#!/bin/bash

AUDIO_FILE=$1
GIF_PFP="";PFP=pfp.jpg
#GIF_PFP="-stream_loop -1";PFP=3ds.gif
PFP_SIZE=200
AUDIO_SECS=$(ffprobe -i $1 -show_entries format=duration -v quiet -of csv="p=0")
COLOR="#ff80b3"
TEXT_COLOR="#ffffffbb"
TEXT_SIZE=24
ffmpeg -y -i $AUDIO_FILE \
  -f lavfi -i color=c=$COLOR:s=640x360 \
  $GIF_PFP -i $PFP -i circle.png \
  -i speaker.png \
  -filter_complex \
    "[2:v]scale=$PFP_SIZE:$PFP_SIZE[profile];\
    [3:v]scale=$PFP_SIZE:$PFP_SIZE[alpha_mask];\
    [profile][alpha_mask]alphamerge[masked_profile];\
    [1]drawtext=text='⬤':fontfile=symbols.ttf:x=(W-text_w)/2:y=(H-text_h)/2:fontsize=$PFP_SIZE+sin(t*6)*30:fontcolor=$TEXT_COLOR[bg];\
    [bg][masked_profile]overlay=x=(W-w)/2:y=(H-h)/2[bg];\
    [bg]drawtext=text='%{eif\:floor(($AUDIO_SECS-t)/60)\:d\:1}\:%{eif\:mod(($AUDIO_SECS-t)\,60)\:d\:2}'\
    :fontfile=Chirp-Regular.woff2:x=20:y=H-35:fontsize=$TEXT_SIZE:fontcolor=$TEXT_COLOR[bg];\
    [bg][4:v]overlay=x=78:y=H-37[bg];\
    [bg]drawtext=text='Voice':fontfile=Chirp-Bold.woff2:x=(W-text_w)-20:y=H-35:fontsize=$TEXT_SIZE:fontcolor=$TEXT_COLOR;"\
  -c:v libx264 -c:a aac -strict experimental -t $AUDIO_SECS output.mp4
