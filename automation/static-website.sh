#!/bin/sh

set -e

TWBASE="/var/lib/tiddlywiki"
HTDOCS="$TWBASE/htdocs"

find "$TWBASE/mywiki" \
  -name '*.tid' \
  -and -not -name '$__StoryList.*' \
  -mmin -1 | while read -r tid
do
  echo "Generate static version of $tid in $HTDOCS."
	#tiddlywiki mywiki --rendertiddler "$tid" "$tid.html" text/plain
done

##!/bin/bash
#
#function decode() {
#	printf '%b' "${1//%/\\x}"
#}
#
#if [ -d mywiki/tiddlers ]
#then
#	tiddlywiki mywiki --rendertiddler $:/core/templates/alltiddlers.template.html index.html text/plain
#	tiddlywiki mywiki --rendertiddlers '[!is[system]]' $:/core/templates/static.tiddler.html static text/plain
#	tiddlywiki mywiki --rendertiddler $:/core/templates/static.template.css static/static.css text/plain
#	rsync -a --delete --delete-after mywiki/output/static/ /var/www/static/
#	rsync -a mywiki/output/index.html /var/www/static/
#	cd /var/www/static
#	find . -mindepth 1 -maxdepth 1 -type f | while read file
#	do
#		lcfile="${file,,}"
#		for symlink in "$lcfile" "$(decode "$file")" "$(decode "$lcfile")" \
#				"$(decode "$file" | tr " " "_")" "$(decode "$lcfile" | tr " " "_")" \
#				"$(decode "$file" | tr -d " ")" "$(decode "$lcfile" | tr -d " ")"
#		do
#			if ! [ "$symlink" == "$file" ] && ! [[ -e  "$symlink" ]]
#			then
#				ln -s "$file" "$symlink"
#			fi
#		done
#	done
#fi
