#!/bin/sh
#####################################################################
# Licence:
#
# (C) 2015 Michael F. Herbst <info@michael-herbst.com>
#
# root-encrypt is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# It is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# A copy of the GNU General Public License can be found 
# at <http://www.gnu.org/licenses/>.
#
#####################################################################

TARGETDIR=/var/lib/root-encrypt
NEWKEY="$1"

if [ ! "$NEWKEY" ]; then
	echo "Please provide new keyfile as first arg."
	exit 1
fi

if [ ! -f "$NEWKEY" ]; then
        echo "Could not find keyfile: \"$NEWKEY\"" >&2
        exit 1
fi

set -e

cp "$NEWKEY" "$TARGETDIR/key.asc"
chown root-encrypt:root-encrypt "$TARGETDIR/key.asc"
su -s /bin/sh root-encrypt -c "gpg --import $TARGETDIR/key.asc"

