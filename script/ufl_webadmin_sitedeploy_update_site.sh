#!/bin/sh

REPO="$1"
SVNNOTIFY_CONFIG="svnnotify.yml"

if /usr/bin/svnlook cat "$REPO" "$SVNNOTIFY_CONFIG" > /dev/null 2> /dev/null; then
    /usr/bin/perl -MSVN::Notify::Config="file://$REPO/$SVNNOTIFY_CONFIG" -e1 $@
fi
