#!/bin/bash
set -x

rm -rf ./bin
echo $1
if [ ! -d bin ]; then
  mkdir bin
fi


if [ ! -d bin/lib ]; then
  mkdir bin/lib
fi

cp $1 bin/

ldd  $1 > ldd_output.txt

while read -r line; do
  if [[ $line == *" => "* ]]; then
    library_path=$(echo "$line" | awk -F" => " '{print $2}' | awk '{print $1}')
    if [ -n "$library_path" ]; then
      cp -v "$library_path" bin/lib/
    fi
  fi
done < ldd_output.txt

rm ldd_output.txt

file_name=$(basename "$1")

binary="./bin/"$file_name
lib_dir="./bin/lib"

mkdir -p "$lib_dir"

dependencies=$(ldd "$binary" | awk '{if ($3 != "statically" && $3 != "not") print $1}')


patchelf --set-rpath "$lib_dir" "$binary"
