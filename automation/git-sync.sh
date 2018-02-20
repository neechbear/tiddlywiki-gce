#!/bin/sh

set -e

TWBASE="/var/lib/tiddlywiki"

cd "$TWBASE"
git add -A
git commit -a -m "Automatic commit."
