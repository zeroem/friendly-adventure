#!/bin/bash

declare -r dist_dir="$(cd "$(dirname "$0")"/../dist; pwd)"
declare -r love_osx="${dist_dir}/love-osx.zip"
declare -r package_name="friendly-adventure.app"

if [ ! -f "$love_osx" ]; then
  wget --quiet --continue "https://bitbucket.org/rude/love/downloads/love-0.10.1-macosx-x64.zip" -O "$love_osx"
fi

cd "$dist_dir"
unzip "$love_osx"

rm -rf "$package_name"
rm -rf friendly-adventure-osx.zip
mv love.app "${package_name}"

cp friendly-adventure.love "$package_name"/Contents/Resources
cp Info.plist "$package_name"/Contents/

zip -y -r friendly-adventure-osx.zip "$package_name"
