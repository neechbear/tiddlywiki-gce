#!/bin/sh

# MIT License
# Copyright (c) 2018 Nicola Worthington <nicolaw@tfb.net>

set -e

TWBASE="/var/lib/tiddlywiki"

cd "$TWBASE"
git add -A
git commit -a -m "Automatic commit."
