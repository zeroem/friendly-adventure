#!/bin/bash

declare -r bin_dir="$(cd "$(dirname "$0")"; pwd)";

"$bin_dir"/make-love.sh
"$bin_dir"/package-osx.sh
"$bin_dir"/package-win32.sh
