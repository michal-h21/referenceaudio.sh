#!/bin/bash
# replace original audio in video file with better one, possibly from microphone
SCRIPTDIR=`dirname "$(readlink -f "$0")"`
SCRIPTNAME=$SCRIPTDIR/correlate_audio.praat

if [ $# -lt 2 ]; then
  echo "Usage: $0 videofile referenceaudio outfile"
  exit 1
fi

# extract audio from video
echo "Extract audo from video"
VIDEOAUDIO=`mktemp --suffix .wav`
# we don't want ffmpeg to ask for overwrite
rm $VIDEOAUDIO
# it needs to be in the same quality as the sound from the reference audio
ffmpeg -i $1 -vn -acodec pcm_s16le -ar 44100 -ac 2 $VIDEOAUDIO

echo "Calculate time shift"
# use praat to get the difference
DIFF=`praat $SCRIPTNAME $VIDEOAUDIO "$(readlink -f "$2")"`

# we don't need videoaudio anymore
rm $VIDEOAUDIO

echo "Shifting audio"
# make new audio shifted by the amount of time reported by praat
TRIMAUDIO=`mktemp --suffix .wav`
rm $TRIMAUDIO
ffmpeg -i $2 -ss $DIFF $TRIMAUDIO


echo "Create new video $3"
# use new audio 
ffmpeg -i $1 -i $TRIMAUDIO -c:v copy -map 0:v:0 -map 1:a:0 $3

# final cleanup
rm $TRIMAUDIO 
