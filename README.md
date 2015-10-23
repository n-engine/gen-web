# - LICENCE -
 This is free and unencumbered software released into the public domain.
 
 Anyone is free to copy, modify, publish, use, compile, sell, or
 distribute this software, either in source code form or as a compiled
 binary, for any purpose, commercial or non-commercial, and by any
 means.
 
 In jurisdictions that recognize copyright laws, the author or authors
 of this software dedicate any and all copyright interest in the
 software to the public domain. We make this dedication for the benefit
 of the public at large and to the detriment of our heirs and
 successors. We intend this dedication to be an overt act of
 relinquishment in perpetuity of all present and future rights to this
 software under copyright law.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.

# For more information, please refer to <http://unlicense.org/>

# -- README --

# - SUMMARY -

# Extract image from video and create nor transcode it to :
 - Gif image
 - WebM
 - Png (for preview image)
 - Flv video
 - Time code file (to keep a trace of what and how it was made)


# - WHY ? -

  On the web I see people looking for the same command here and here
  asking how to generate gif, flv nor webm file.
  So, i made this script for who are alooking
  to generate easily web content.
  It is easy to generate web file as the gif, flv, nor webm
  and can be easily changed to meet the need of the users.


# - DEPENDENCY -

 This script depend on these tools :
 -----------------------------------
  bash               : http://tiswww.case.edu/php/chet/bash/bashtop.html
  avconv             : http://libav.org
  convert            : http://www.imagemagick.org
  mediainfo          : http://mediaarea.net

 All of these tool can be easily installed with one command line :

  (sudo) apt-get install bash awk mediainfo ffmpeg imagemagick

# - COMMAND -

 gen_web [video_input] [star_time] [duration_time] [outputname (optional)]

 [video_input]    source input (ex.: file.mpg)
 [star_time]      00:00:00 or time in second (ex.: 00:00:48 or 48)
 [duration_time]  00:00:00 or time in second (ex.: 00:00:05 or 5)
 [outputname]     outputname (ex.: ~/my_output_path)

 If output name is not given, the file output will be done in the current
 directory with base name of [video_input].

 These files are created by default :

  [outputname]_preview.png
  [outputname].gif
  [outputname].webm
  [outputname].flv
  [outputname].rs

 Optional: if you do not want flv gif webm or preview image you can 
 set environment variable to ignore one of these output format

  NO_FLV=1  : does not create flv file
  NO_GIF=1  : does not create gif file
  NO_WEBM=1 : does not create webm file
  NO_PREV=1 : does not create preview file

 Other options :

  NO_DEBUG=1    : no output message
  ALLYES=1      : answer yes to all question
  NO_OPTIMIZE=1 : no gif optimization.
  FULLSPEED=1   : make bigger file but keep a more "speed" framerate.
  MAXSIZE=width : set the default maximum width for the gif image
                  aspect is automatically kept.

# - EXAMPLE USAGE -

  Get a video source :
  --------------------

  URL=http://upload.wikimedia.org/wikipedia/commons/7/75
  FILE=Big_Buck_Bunny_Trailer_400p.ogg
  wget ${URL}/${FILE} 

# Ex.1 : Generate with default option our web file :

 ~/bin/gen_web ${FILE} 00:00:14 00:00:02 bigbuck_std

  this will generate these files :
  --------------------------------
   118870 bigbuck_std.flv
   172275 bigbuck_std.gif
   427165 bigbuck_std_preview.png
       71 bigbuck_std.rs
    63410 bigbuck_std.webm


# Ex.2 : no output path is given :

  ~/bin/gen_web ${FILE} 00:00:14 00:00:02

# Ex.3 : Generate non optimized video with high speed data, no flv :

  FULLSPEED=1 NO_OPTIMIZE=0 NO_FLV=1 \
  ~/bin/gen_web ${FILE} 00:00:14 00:00:02 bigbuck_full


# Ex.4: recreate web file from reference script ([filename].rs) file :

  source bigbuck_std/bigbuck_std.rs
  $GEN_WEB

# - TESTED ON PLATFORM -
 
  Debian weezy Jan 2015
  Debian jessie Oct 2015

# - AUTHOR -

  ESTEVE Olivier (naskel [@] gmail [.] com)


 Rev: 1 (Octobre 2015)
  removed dependency of ImageMagic (thanks to great filter of ffmpeg)
