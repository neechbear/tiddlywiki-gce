#!/bin/sh

# MIT License
# Copyright (c) 2018 Nicola Worthington <nicolaw@tfb.net>

# https://tiddlywiki.com/static/RenderCommand.html
# https://tiddlywiki.com/static/Generating%2520Static%2520Sites%2520with%2520TiddlyWiki.html
# https://tiddlywiki.com/static/RenderTiddlerCommand.html
# https://tiddlywiki.com/static/RenderTiddlersCommand.html

set -e

# TODO: Due to this being a busybox ash script rather than bash, I've been
#       somewhat lax with the use of global variables instead of passing
#       arguments to each function. I should fix this.

export TWBASE="/var/lib/tiddlywiki"
export HTDOCS="$TWBASE/htdocs"

changed_tiddlers () {
  change_mins="$1"
  if [ -z "$change_mins" ]; then
    change_mins=30
  fi
  find "$TWBASE/mywiki" \
    -name '*.tid' \
    -mmin "-$change_mins" \
    -and -not \( \
          -name '$__StoryList.tid' \
      -or -name 'StoryList.tid' \
      \)
}

urldecode () {
  busybox httpd -d "$@"
}

urlencode () {
  echo "$@" | awk -v ORS="" '{ gsub(/./,"&\n") ; print }' | while read l
  do
    case "$l" in
      [-_.~a-zA-Z0-9] ) echo -n ${l} ;;
      "" ) echo -n %20 ;;
      * )  printf '%%%02X' "'$l"
    esac
  done
  echo ""
}

next_static_dir () {
  case $(readlink "$HTDOCS/static") in
    static-a) echo "static-b" ;;
    static-b) echo "static-a" ;;
    *)        echo "static-a" ;;
  esac
}

tw () {
  output="$(next_static_dir)"
  set -x
  tiddlywiki "$TWBASE/mywiki" \
    --output "$HTDOCS/$output" \
    "$@"
  { set +x; } 2>/dev/null
}

generate_static_tiddlers () {
  next_static_dir="$1"

  rm -Rf "$HTDOCS/$next_static_dir"/*
  tw --render "[!is[system]]" "[encodeuricomponent[]addsuffix[.html]]" text/plain $:/core/templates/static.tiddler.html 
  tw --rendertiddler $:/core/templates/static.template.css static.css text/plain
  #tw --rendertiddler $:/core/templates/static.template.html index.html text/plain

  cd "$HTDOCS/$next_static_dir"

  default="$(sed -n '/^$/{n;p}' \
    "$TWBASE/mywiki/tiddlers/\$__DefaultTiddlers.tid")"
  if [ ! -e index.html ] || [ -h index.html ]; then
    ln -sfn "$(urlencode "$default").html" "index.html"
  fi

  find . -mindepth 1 -maxdepth 1 -type f | cut -b3- | while read file
  do
    lcfile="$(echo "$file" | tr "A-Z" "a-z")"
    for symlink in "$lcfile" \
                   "$(urldecode "$file")" \
                   "$(urldecode "$lcfile")" \
                   "$(urldecode "$file" | tr " " "_")" \
                   "$(urldecode "$lcfile" | tr " " "_")" \
                   "$(urldecode "$file" | tr -d " ")" \
                   "$(urldecode "$lcfile" | tr -d " ")" \
                   "$(urldecode "$file" | tr -d "_")" \
                   "$(urldecode "$lcfile" | tr -d "_")"
    do
      symlink="$(echo "$symlink" | tr "/" "-")"
      if [ ! "$symlink" = "$file" ] && [ ! -e  "$symlink" ]; then
        ln -s "$file" "$symlink" || true
      fi
    done
  done
}

main () {
  change_mins="$1"
  cd "$HTDOCS"

  # TODO: See if we can work out a more tidy method of performing an atomic
  #       update, such that does not commit two static content directories to
  #       the upstream Git repository.
  for dir in static-a static-b
  do
    if [ ! -d "$HTDOCS/$dir" ]; then
      mkdir -p "$HTDOCS/$dir"
    fi
  done

  changed_tiddlers "$change_mins" | while read -r tid
  do
    echo "Discovered modified tiddler $tid."
  done

  if [ -n "$(changed_tiddlers "$change_mins")" ]; then
    echo "Generating static tiddlers in $HTDOCS."
    generate_static_tiddlers "$(next_static_dir)"
    cd "$HTDOCS"
    ln -sfn "$next_static_dir" static
  fi
}

main "$@"
