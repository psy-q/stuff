#!/bin/bash
# $1 is the output file path
avconv -f alsa -i pulse -f x11grab -r 30 -s 1280x720 -i :0.0+1366,0 -acodec libvorbis -vcodec libx264 -pre:0 lossless_ultrafast -threads 0 $1 
