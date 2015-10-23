#!/bin/bash

## - LICENCE -
#
###############################################################################
# This is free and unencumbered software released into the public domain.
# 
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
# 
# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# For more information, please refer to <http://unlicense.org/>
#
###############################################################################

###
##
## -- README --
##
## - SUMMARY -
##
## Extract image from video and create nor transcode it to :
##
## - Gif image
## - WebM
## - Png (for preview image)
## - Flv video
## - Time code file (to keep a trace of what and how it was made)
##
##
## - WHY ? -
##
##  On the web I see people looking for the same command here and here
##  asking how to generate gif, flv nor webm file.
##  So, i made this script for who are alooking
##  to generate easily web content.
##  It is easy to generate web file as the gif, flv, nor webm
##  and can be easily changed to meet the need of the users.
##
##
## - DEPENDENCY -
##
## This script depend on these tools :
## -----------------------------------
##  bash               : http://tiswww.case.edu/php/chet/bash/bashtop.html
##  avconv             : http://libav.org
##  convert            : http://www.imagemagick.org
##  mediainfo          : http://mediaarea.net
##
## All of these tool can be easily installed with one command line :
##
##  (sudo) apt-get install bash awk mediainfo ffmpeg imagemagick
##
## - COMMAND -
##
## gen_web [video_input] [star_time] [duration_time] [outputname (optional)]
##
## [video_input]    source input (ex.: file.mpg)
## [star_time]      00:00:00 or time in second (ex.: 00:00:48 or 48)
## [duration_time]  00:00:00 or time in second (ex.: 00:00:05 or 5)
## [outputname]     outputname (ex.: ~/my_output_path)
##
## If output name is not given, the file output will be done in the current
## directory with base name of [video_input].
##
## These files are created by default :
##
##  [outputname]_preview.png
##  [outputname].gif
##  [outputname].webm
##  [outputname].flv
##  [outputname].rs
##
## Optional: if you do not want flv gif webm or preview image you can 
## set environment variable to ignore one of these output format
##
##  NO_FLV=1  : does not create flv file
##  NO_GIF=1  : does not create gif file
##  NO_WEBM=1 : does not create webm file
##  NO_PREV=1 : does not create preview file
##
## Other options :
##
##  NO_DEBUG=1    : no output message
##  ALLYES=1      : answer yes to all question
##  NO_OPTIMIZE=1 : no gif optimization.
##  FULLSPEED=1   : make bigger file but keep a more "speed" framerate.
##  MAXSIZE=width : set the default maximum width for the gif image
##                  aspect is automatically kept.
##
## - EXAMPLE USAGE -
##
##  Get a video source :
##  --------------------
##
##  URL=http://upload.wikimedia.org/wikipedia/commons/7/75
##  FILE=Big_Buck_Bunny_Trailer_400p.ogg
##  wget ${URL}/${FILE} 
##
## Ex.1 : Generate with default option our web file :
##
## ~/bin/gen_web ${FILE} 00:00:14 00:00:02 bigbuck_std
##
##  this will generate these files :
##  --------------------------------
##   118870 bigbuck_std.flv
##   172275 bigbuck_std.gif
##   427165 bigbuck_std_preview.png
##       71 bigbuck_std.rs
##    63410 bigbuck_std.webm
##
##
## Ex.2 : no output path is given :
##
##  ~/bin/gen_web ${FILE} 00:00:14 00:00:02
##
## Ex.3 : Generate non optimized video with high speed data, no flv :
##
##  FULLSPEED=1 NO_OPTIMIZE=0 NO_FLV=1 \
##  ~/bin/gen_web ${FILE} 00:00:14 00:00:02 bigbuck_full
##
##
## Ex.4: recreate web file from reference script ([filename].rs) file :
##
##  source bigbuck_std/bigbuck_std.rs
##  $GEN_WEB
##
## - TESTED ON PLATFORM -
## 
##  Debian weezy Jan 2015
##  Debian jessie Oct 2015
##
## - AUTHOR -
##
##  ESTEVE Olivier (naskel [@] gmail [.] com)
##
##
## Rev: 1 (Octobre 2015)
##  removed dependency of ImageMagic (thanks to great filter of ffmpeg)
##
###############################################################################

## Variable used in this script
PROGNAME="$0"
INAME="$1"
ITIME="$2"
OTIME="$3"
ONAME="$4"
OPATH="${ONAME}"
TDIR=.$$.tmp
IWIDTH=
IHEIGHT=
OWIDTH=
OHEIGHT=
IMAXSIZE=320
IFPS=

## Minimum required tools #####################################################
#AVCONV=$(which avconv)
AVCONV=ffmpeg
BASENAME=$(which basename)
AWK=$(which awk)
MINFO=$(which mediainfo)
#CONVERT=$(which convert)

## Minimum required tools #####################################################
TEST_BASENAME=$(${BASENAME} --version >/dev/null 2>&1)
TEST_AWK=$(${AWK} -W version >/dev/null 2>&1)
TEST_MINFO=$(${MINFO} --Version >/dev/null 2>&1)
#TEST_CONVERT=$(${CONVERT} -version >/dev/null 2>&1)
TEST_AVCONV=$(${AVCONV} -version >/dev/null 2>&1)

#
## function used in this script
#

help() {
cat <<EOF

$0 [video_input] [star_time] [duration_time] [outputname (optional)]

 [video_input]    source input (ex.: file.mpg)
 [star_time]      00:00:00 or time in second (ex.: 00:00:48 or 48)
 [duration_time]  00:00:00 or time in second (ex.: 00:00:05 or 5)
 [outputname]     outputname (ex.: ~/my_output_path)

 Optional: if you do not want flv gif webm or preview image you can 
 set environment variable to ignore one of these output format

  NO_FLV=1  : does not create flv file
  NO_GIF=1  : does not create gif file
  NO_WEBM=1 : does not create webm file
  NO_PREV=1 : does not create preview file

 Other options :

  NO_OPTIMIZE=1 : no gif optimization.
  FULLSPEED=1   : make bigger file but keep a more "speed" framerate.
  MAXSIZE=width : set the default maximum width for the gif image
                  aspect is automatically kept.

EOF
 exit 0
}

debug() {
 test x"${NO_DEBUG}" = "x1" && return
 echo "$@"	
}

try() {
 debug "$@"
 "$@"
}

genWait() {
 debug "Generating $1 ... please wait."
}

error() {
 echo "${PROGNAME} $@"
 exit 0
}

asksure() {
 test x"${ALLYES}" = "x1" && return 1
 echo -n "destination folder already exist delete it (Y/N)? "
 while read -r -n 1 -s answer; do
  if [[ $answer = [YyNn] ]]; then
    [[ $answer = [Yy] ]] && retval=0
    [[ $answer = [Nn] ]] && retval=1
    break
  fi
 done
 echo
 return $retval
}

checkInput() {
 INPUT=$(eval echo "\$1")
 #echo $INPUT
 if [ x"${INPUT}" = "x" ]; then
  error "Invalid input name: $$1"
 fi
}

## get the width and height of the input video
getSize() {
 INF="${INAME}"
 IWIDTH=$(${MINFO} "${INF}"|grep Width|${AWK} {'print $3'})
 IHEIGHT=$(${MINFO} "${INF}"|grep Height|${AWK} {'print $3'})
 OWIDTH="${IWIDTH}"
 OHEIGHT="${IHEIGHT}"
 echo "${INAME} \"${OWIDTH}\" -gt \"${IMAXSIZE}\""
 if [[ -z "${OWIDTH}" || -z "${OWIDTH}" || -z "${IMAXSIZE}" ]]; then
  error "Invalid source file: ${INAME}"
 fi
 if [ "${OWIDTH}" -gt "${IMAXSIZE}" ]; then
  OWIDTH="${IMAXSIZE}"
  OHEIGHT=$(${AWK} "BEGIN {printf ${IHEIGHT} / ${IWIDTH} * ${OWIDTH}}")
  export OWIDTH OHEIGHT
 fi
 export IWIDTH IHEIGHT OWIDTH OHEIGHT
 if [[ "${IWIDTH}" = "" || "${IHEIGHT}" = ""  || "${OWIDTH}" = ""  ]]; then
  return 1;
 fi
 return 0
}

## return the fps of the video
getFps() {
 INF="${INAME}"
 ${MINFO} "${INF}"
 IFPS=$(${MINFO} "${INF}"|grep "fps"|${AWK} '{printf "%d",$5}')
 export IFPS
 if [[ -z "${IFPS}" || "${IFPS}" = "" || "${IFPS}" = "0" ]]; then
  IFPS=15
  export IFPS
 fi
 return 0
}

getInfo() {
	genWait info
	getSize
	getFps
}

## generate the WebM file
genWebM() {
 AUDIOS="-acodec libvorbis"
 test x"${NO_WEBM}" = "x1" && return 0
 test x"${NO_AUDIO}" = "x1" && AUDIOS="-an"
 genWait webm
  try ${AVCONV} -i "${TDIR}/output.avi" \
  -vcodec libvpx ${AUDIOS} -qmin 0 -qmax 50 -crf 5 -b:v 2M \
  "${OPATH}/${ONAME}.webm" \
  >/dev/null 2>&1 || return 1
 return 0
}

## generate the flv file
genFlv() {
 AUDIOS="-ar 44100"
 test x"${NO_FLV}" = "x1" && return 0
 test x"${NO_AUDIO}" = "x1" && AUDIOS="-an"
 genWait flv
 try ${AVCONV} -i "${TDIR}/output.avi" -r ${IFPS} \
  -b 270k ${AUDIOS} "${OPATH}/${ONAME}.flv" || return 1
  return 0
}

## generate the image list used for create every thing
genTemp() {
 genWait "temp data"
 try ${AVCONV} -i "${INAME}" -ss "${ITIME}" -t "${OTIME}" \
   -acodec copy -vcodec ffv1 -b 4096k "${TDIR}/output.avi" || \
   return 1
 return 0
}

genPreview() {
 test x"${NO_PREV}" = "x1" && return 0
 genWait preview
 try ${AVCONV} -i "${TDIR}/output.avi" \
  -an -vframes 1 "${OPATH}/${ONAME}_preview.png" >/dev/null 2>&1 || return 1
 return 0
}

## generate the output gif file
genGif() {
 test x"${NO_GIF}" = "x1" && return
 genWait gif
 DELAY="-delay 1x8"
 if [ x"${FULLSPEED}" = "x1" ]; then
  DELAY="-delay 5"
 fi
 ## new
 PALETTE="${TDIR}/palette.png"
 FILTERS="fps=${IFPS},scale=${OWIDTH}:-1:flags=lanczos"
 ${AVCONV} -v warning -i ${TDIR}/output.avi \
  -vf "${FILTERS},palettegen" -y ${PALETTE}
 ${AVCONV} -v warning -i ${TDIR}/output.avi -i ${PALETTE} -lavfi \
  "${FILTERS} [x]; [x][1:v] paletteuse" -y "${OPATH}/${ONAME}.gif"
 ## old way
# if [ x"${NO_OPTIMIZE}" = "x1" ]; then
# ${AVCONV} -i "${TDIR}/output.avi" \
#  -vf scale=${OWIDTH}:-1 -r ${IFPS} \
#  -f image2pipe -vcodec ppm - | \
#  ${CONVERT} -loop 1 -layers Optimize - "${OPATH}/${ONAME}.gif" \
#  >/dev/null 2>&1 || return 1
# else
# ${AVCONV} -i "${TDIR}/output.avi" \
#  -vf scale=${OWIDTH}:-1 -r ${IFPS} \
#  -f image2pipe -vcodec ppm - | \
#  ${CONVERT} ${DELAY} -loop 1 -coalesce -layers Optimize - \
#  "${OPATH}/${ONAME}.gif" >/dev/null 2>&1 || return 1
# fi
 return 0
}

genRef() {
cat<<EOF >  "${OPATH}/${ONAME}.rs"
NO_DEBUG="${NO_DEBUG}"
ALLYES="${ALLYES}"
NO_AUDIO="${NO_AUDIO}"
NO_FLV="${NO_FLV}"
NO_GIF="${NO_GIF}"
NO_WEBM="${NO_WEBM}"
NO_PREV="${NO_PREV}"
NO_OPTIMIZE="${NO_OPTIMIZE}"
FULLSPEED="${FULLSPEED}"
MAXSIZE="${MAXSIZE}"
SOURCE="${INAME}"
FROM="${ITIME}"
TO="${OTIME}"
OUT="${OPATH}"
GEN_WEB="${PROGNAME} "\${SOURCE}" \${FROM} \${TO} \${OUT}"
EOF
return $?
}

##
## sanity check
##
[[ -z "$1" || "$1" = "--help" || "$1" = "-h" || "$1" = "help" ]] && help

checkInput TEST_AVCONV
checkInput TEST_AWK
checkInput TEST_BASENAME
#checkInput TEST_CONVERT
checkInput TEST_MINFO

## get value of maxsize if needed
if [ ! -z ${MAXSIZE} ]; then
 IMAXSIZE=${MAXSIZE}
fi

## check optionnal output name
if [ x"$4" = "x" ]; then
 ONAME=$(basename ${INAME} | cut -d. -f1)
 OPATH="${ONAME}"
 export ONAME OPATH
fi

## check output path
if [ -d "${OPATH}" ]; then
 if asksure; then
  rm -rf "${OPATH}"
 else
  exit 1
 fi
fi

## create temp directory and output path
mkdir -p "${TDIR}" "${OPATH}" || \
 error "cant create output path nor temp directory"

## sanity check: input options
checkInput INAME
checkInput ITIME
checkInput OTIME
checkInput ONAME
checkInput OPATH

## generate output file
debug
genRef || error "cant generate reference script"
getInfo || error "cant get info from video file"
genTemp || error "cant generate temp data"
genPreview || error "cant generate preview image"
genFlv || error "cant generate Flv video"
genWebM || error "cant generate WebM video"
genGif || error "cant generate Gif image"

## delete temporary file
rm -rf "${TDIR}" || error "cant remove temp directory: ${TDIR}"

debug "All done."
debug
