#! /usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

for project in $DIR/../go/*; do
  if [ -d $project ]; then
    project_name=$(basename $project)
    echo "Installing $project_name"
    cd $project
    go build -o $GOPATH/bin/$project_name
  fi
done
