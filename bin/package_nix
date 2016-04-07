#!/bin/bash -e

declare -r project_dir="$(cd "$(dirname "$0")"/..; pwd)"

cd "$project_dir"

mkdir -p "$project_dir"/dist

zip -9 -r dist/friendly-adventure.love $(find * -type f -name "*.lua") assets/
