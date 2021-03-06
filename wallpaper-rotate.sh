#!/usr/bin/env /bin/bash

# USE AT YOUR OWN RISK! IN CASE OF FIRE OR CATASTROPHIC FAILURE,
# CALL 911 AND OTHER APROPRIATE AUTHORITIES!
#
# tsouchlarakis@gmail.com 2016.10.05
#
# GNU/GPL https://www.gnu.org/licenses/gpl.html
#

# Simple script to go through a directory of background images
# as wallpapers in a timely fashion

# set -aeu

WR_USAGE=$(cat <<EOF
\n
Quick and dirty script to rotate backgrounds \n
in wm's with out such options (ie NOT kde, gnome or xfce4)\n
\n
Usage: source wallpaper-rotate.sh && rbgHelperAddDir /home/user/pictures && rotateBg\n
(rbgHelperAddDir /home/user/pictures needs to be executed only once per pictures directory.)\n
\n
Alternatively you can source this file in your startup scripts and start it from there.\n
\n
EOF
)

function rotateBg() {
  # Find a setter or die trying
  if [[ -x $(which feh) ]]; then
    BGSETTER="feh --bg-scale "
  elif [[ -x $(which wmsetbg) ]]; then
    BGSETTER="wmsetbg "
  elif [[ -x $(which fvwm-root) ]]; then
    BGSETTER="fvwm-root "
  elif [[ -x $(which fbsetbg) ]]; then
    BGSETTER="fbsetbg "
  elif [[ -x $(which bsetbg) ]]; then
    BGSETTER="bsetbg "
  elif [[ -x $(which hsetroot) ]]; then
    BGSETTER="hsetroot -fill "
  elif [[ -x $(which xsetroot) ]]; then
    BGSETTER="xsetroot -bitmap "
  else
    echo -e "${WR_USAGE}"
    return 1
  fi

  # Assign a default wp dir
  DEFAULT_WPDIR="${HOME}/.wallpaper"
  # and a default wait interval
  DEFAULT_WAIT="60s"

  # If there is a readable settings file, read it
  if [[ -r "${HOME}"/.wallpaper.rotate.rc ]]; then
    source "${HOME}"/.wallpaper.rotate.rc
  fi

  # take second argument as a wp dir or assign a default.
  WPD=${2-${DEFAULT_WPDIR}}
  # fill array with values
  WPL=( $(ls ${WPD}) )
  # get array upper bound
  WPN=${#WPL[*]}

  while true ; do
    # limit a random num to upper array bounds
    #let "RN = $RANDOM % $WPN"
    RN=$(shuf -n 1 -i 0-"${WPN}")
    # Get path and name of image
    WP="${WPD}/${WPL[$RN]}"
    # Check if item is a symlink
    if [[ -L "${WP}" ]]; then
      # set wallpaper, wait
      ${BGSETTER} "${WP}"
      sleep ${1-${DEFAULT_WAIT}}
    else
      # Try again later
      sleep ${1-${DEFAULT_WAIT}}
    fi
  done
}

# Helper function to populate "~/.wallpapers" directory with links to image files.
#
# First time use of rotateBg, you'll need to run this function first
# with an image file directory as parameter to initialize "~/.wallpapers".
# (create "~/.wallpapers" and populate it)
#
# Call this function with the dir you'd like to add its images as links in "~/.wallpapers"
# for use with "rotateBg" function. eg: "rbgHelperAddDir /home/user/pictures"
function rbgHelperAddDir {
  # Assign a default wp dir
  DEFAULT_WPDIR="${HOME}/.wallpapers"
  # If there is a readable settings file, read it
  if [ -r ${HOME}/.wallpaper.rotate.rc ]; then
    source ${HOME}/.wallpaper.rotate.rc
  fi
  # What errors?
  mkdir "${DEFAULT_WPDIR}" 2> /dev/null
  for i in $(ls "${1}"); do
    # Get file extention ${str:(-4)}
    FE="${i:(-4)}"
    # and lowercase it ${str,,}
    if [[ "${FE,,}" == ".jpg" || "${FE,,}" == ".jpe" || "${FE,,}" == ".png" || "${FE,,}" == ".gif" || "${FE,,}" == ".bmp" ]]; then
      ln -sf "${1}"/"${i}" "${DEFAULT_WPDIR}"/"${i}"
    fi
  done
}

# Helper function to remove links of images from a given directory in "~/.wallpapers"
#
# Means to remove a directory (previously added with rbgHelperAddDir /home/user/pictures)
# from use with "rotateBg"
#
# Use this function with the unwanted dir as its sole parameter
# eg: "rbgHelperRemoveDir /home/user/pictures"
# It is meant to be called interactively and not from within scripts
function rbgHelperRemoveDir {
  # Assign a default wp dir
  DEFAULT_WPDIR="${HOME}/.wallpapers"
  # If there is a readable settings file, read it
  if [[ -r ${HOME}/.wallpaper.rotate.rc ]]; then
    source ${HOME}/.wallpaper.rotate.rc
  fi
  for i in $(ls "${1}"); do
    # Get file extention ${str:(-4)}
    FE="${i:(-4)}"
    # and lowercase it ${str,,}
    if [[ "${FE,,}" == ".jpg" || "${FE,,}" == ".jpe" || "${FE,,}" == ".png" || "${FE,,}" == ".gif" || "${FE,,}" == ".bmp" ]]; then
      rm -i "${DEFAULT_WPDIR}"/"${i}"      # rm --interactive just to play it safe, this func
    fi
  done
}
