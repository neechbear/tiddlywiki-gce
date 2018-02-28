#!/bin/sh

# MIT License
# Copyright (c) 2018 Nicola Worthington <nicolaw@tfb.net>

set -e

TWBASE="/var/lib/tiddlywiki"

cd "$TWBASE"

if [ ! "$(git diff --shortstat 2> /dev/null | tail -n1)" = "" ]
then
  git add -A
  git commit -a -m "Automatic commit."
  git push origin master
fi
