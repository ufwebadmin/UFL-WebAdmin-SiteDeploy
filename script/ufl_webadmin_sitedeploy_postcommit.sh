#!/bin/sh

# POST-COMMIT HOOK
#
# The post-commit hook is invoked after a commit.  Subversion runs
# this hook by invoking a program (script, executable, binary, etc.)
# named 'post-commit' (for which this file is a template) with the 
# following ordered arguments:
#
#   [1] REPOS-PATH   (the path to this repository)
#   [2] REV          (the number of the revision just committed)
#
# The default working directory for the invocation is undefined, so
# the program should set one explicitly if it cares.
#
# Because the commit has already completed and cannot be undone,
# the exit code of the hook program is ignored.  The hook program
# can use the 'svnlook' utility to help it examine the
# newly-committed tree.
#
# On a Unix system, the normal procedure is to have 'post-commit'
# invoke other programs to do the real work, though it may do the
# work itself too.
#
# Note that 'post-commit' must be executable by the user(s) who will
# invoke it (typically the user httpd runs as), and that user must
# have filesystem-level permission to access the repository.
#
# On a Windows system, you should name the hook program
# 'post-commit.bat' or 'post-commit.exe',
# but the basic idea is the same.

SVNLOOK=/usr/bin/svnlook
SVNNOTIFY=/usr/bin/svnnotify

REPO="$1"
REV="$2"
LOG="$($SVNLOOK log -r "$REV" "$REPO")"
AUTHOR="$($SVNLOOK author -r "$REV" "$REPO")"

TRAC_DIR="/var/lib/trac/$(basename $REPO)"
TRAC_URL="http://trac.webadmin.ufl.edu/$(basename $REPO)"

"$SVNNOTIFY" --repos-path "$REPO" --revision "$REV" --svnlook "$SVNLOOK" --to webadmin-dev-l@lists.ufl.edu --from webmaster@ufl.edu --subject-prefix "[WebAdmin SVN]" --subject-cx --with-diff

if [ -d "$TRAC_DIR" ]; then
    /usr/bin/python /usr/local/bin/trac-post-commit \
	-p "$TRAC_DIR" \
	-r "$REV" \
	-u "$AUTHOR" \
	-m "$LOG" \
	-s "$TRAC_URL"
fi

sudo -u deploybot /usr/bin/ufl_webadmin_sitedeploy_update_site.sh $@
