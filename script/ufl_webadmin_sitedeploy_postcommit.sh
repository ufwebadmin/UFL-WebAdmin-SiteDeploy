#!/bin/sh

sudo -u deploybot /usr/bin/ufl_webadmin_sitedeploy.pl deploy --path "$1" --revision "$2"
