#! /usr/bin/env bash

while read project; do
  filename=$(basename "$project")
  path=${project%"$filename"}
  ponyc "$path";
done < <(find $(pwd) -name "*.pony")
