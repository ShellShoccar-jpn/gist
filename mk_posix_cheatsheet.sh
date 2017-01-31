#!/bin/sh

######################################################################
#
# MK_POSIX_CHEATSHEET.sh :  Make the Cheat Sheet of POSIX Commands
#
# Usage    : mk_posix_cheatsheet.sh [> /PATH/TO/SOME/FILE]
#
# * This command generates the list of the POSIX commands in Hyper text
#   with ONLY the POSIX commands except one of HTTP-GET command. And
#   writes that into the standard output.
#
# * I made sure that this script can generate the HTML text correctly
#   from the Open Group POSIX document site on 2015/09/12. But in the
#   future, it also needs to revise the script for scraping the revised
#   POSIX document.
#
# Required : One of HTTP-GET command (wget or curl or fetch)
#
# Written by Rich Mikan (richmikan[at]richlab.org) on 2015/09/12
#
# This is a public-domain software. It measns that all of the people
# can use this with no restrictions at all. By the way, I am fed up
# the side effects which are broght about by the major licenses.
#
######################################################################


# ====================================================================
# configure
# ====================================================================

# --- POSIX document location (SET THIS) ---
BASE='http://pubs.opengroup.org/onlinepubs/9699919799/'
CMDs='idx/utilities.html'
# --- Others ---
PATH="$(command -p getconf PATH):${PATH:-}"


# ====================================================================
# make sure some depend non-POSIX commands (One of HTTP-GET required)
# ====================================================================

if   type wget  >/dev/null 2>&1; then
  CMD='wget -nv -O -'
elif type curl  >/dev/null 2>&1; then
  CMD='curl -s'
elif type fetch >/dev/null 2>&1; then
  CMD='fetch -q -o -'
else
  printf '%s: No HTTP-GET command found.\n' "${0##*/}" 1>&2
  exit 1
fi


# ====================================================================
# print the previous HTML
# ====================================================================

cat <<PREVIOUS_HTML
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta name="generator" content="HTML Tidy, see www.w3.org">
<link type="text/css" rel="stylesheet" href="${BASE}utilities/style.css">
<title>Utilities</title>
</head>
<body bgcolor="white">
<basefont size="3"> 

<h2>Utilities</h2>


<ul>
PREVIOUS_HTML


# ====================================================================
# print the command list
# ====================================================================

$CMD "${BASE%/}/${CMDs}"                                                     |
sed -n '/a  *href=/{s!.*href="\([^"]*\)".*!'"${BASE%/}/${CMDs%/*}/"'\1!;p;}' |
sed 's![^/]*/\.\./!!'                                                        |
while read url; do                                                           #
  export url                                                                 #
  $CMD "$url"                                             |                  #
  awk 'step==2                   {next  ;              }  #                  #
       step==1 && /blockquote/   {print ; step=2; next;}  #                  #
       /class="mansect".*>NAME</ {step=1; next  ;      }' |                  #
  sed 's!^.*<blockquote>!!'                               |                  #
  sed 's!</blockquote>.*$!!'                              |                  #
  awk 'BEGIN { OFS=""; ORS=""; }                          #                  #
       match($0, /[^ \t]+/) {                             #                  #
         print "<li>"                              ;      #                  #
         print substr($0, 1             , RSTART-1);      #                  #
         print "<a href=\"", ENVIRON["url"], "\">" ;      #                  #
         print substr($0, RSTART        , RLENGTH );      #                  #
         print "</a>"                              ;      #                  #
         print substr($0, RSTART+RLENGTH          );      #                  #
         print "</li>\n"                           ;      #                  #
       }'                                                                    #
done


# ====================================================================
# print the following HTML
# ====================================================================

cat <<FOLLOWING_HTML
</li>
</ul>
<p>
This page was generated with the Open Groups POSIX document site
on $(date '+%Y/%m/%d').
You should refer the <a href="$BASE">original page</a>.<br />
The all copyrights of these documents belong to them. 
</p>
</body>
</html>
FOLLOWING_HTML


# ====================================================================
# finish normally
# ====================================================================
exit 0
