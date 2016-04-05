#!/bin/bash

declare -r dist_dir="$(cd "$(dirname "$0")"/../dist; pwd)"
declare -r love_win="${dist_dir}/love-win32.zip"
declare -r package_name="friendly-adventure.exe"

if [ ! -f "$love_win" ]; then
  wget --quiet --continue "https://bitbucket.org/rude/love/downloads/love-0.10.1-win32.zip" -O "$love_win"
fi

cd "$dist_dir"

rm -rf love-0.10.1-win32
unzip "$love_win"

rm -rf friendly-adventure-win.zip
cat love-0.10.1-win32/love.exe friendly-adventure.love > friendly-adventure.exe

zip -j -r friendly-adventure-win.zip friendly-adventure.exe love-0.10.1-win32/*.dll love-0.10.1-win32/license.txt
