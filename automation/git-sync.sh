#!/bin/sh

# MIT License
# Copyright (c) 2018 Nicola Worthington <nicolaw@tfb.net>

set -e

TWBASE="/var/lib/tiddlywiki"

cd "$TWBASE"

dirty_workspace () {
  [ -n "$(git diff --shortstat 2> /dev/null | tail -n1)" ]
}

untracked_files () {
  [ -n "$(git ls-files --others --exclude-standard)" ]
}

if [ "$1" = "force" ] || dirty_workspace || untracked_files
then
  git branch --set-upstream-to=origin/master master
  if ! git pull --ff-only; then
    echo "TODO - deal with upstream conflict here"
  fi
  git add -A
  git commit -a -m "Automatic commit."
  git push origin master
fi
