#! /usr/bin/env bash
set -ex

DEST_DIR=/tmp/youtube-videos
rm -rf $DEST_DIR
mkdir $DEST_DIR
yt-dlp $1 -o $DEST_DIR/video
sleep 4
mpv $DEST_DIR/video
