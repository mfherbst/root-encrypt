#!/bin/bash
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

KEYIDFILE=keyid		#define the standard keyid to be used
MAILFILE=email		#define the standard email to be used

################################################################

PACKAGE=root-encrypt
TARPREFIX=`date +%Y.%m.%d`-${PACKAGE}

################################################################

obtain_key_mail() {
	# Try to obtain defaults:
	[ -f "${KEYIDFILE}" ] && ID=$(< "${KEYIDFILE}")
	[ -f "${MAILFILE}" ] && MAIL=$( < "${MAILFILE}")

	[ -z "$MAIL" ] && read -p "Please enter the email address to forward root mail to: " MAIL
	[ -z "$ID" ] && read -p "Please enter the long key id of the key used for encryption: " ID

	[ -z "$ID" -o -z "$MAIL" ] && return 1

	if [ ! -f key.asc ]; then
		gpg  --armor --output key.asc --export $ID || return 1
	fi
	
	return 0
}

if ! obtain_key_mail; then
	echo "Error obtaining mail address or key from keyring." >&2
	exit 1
fi

MAILNORM=$(echo "$MAIL" | sed 's/@/_/g; s/\./_/g')
PUBLISHNAME="${TARPREFIX}_$ID_$MAILNORM.tar.gz"

rm -rf "$PUBLISHNAME" .tempDist/
mkdir .tempDist
cp -a "${PACKAGE}" .tempDist

mv key.asc ".tempDist/${PACKAGE}/"
cd .tempDist
echo "|\"TTAARRGGEETT/encrypt_mail.sh $MAIL $ID\"" > "${PACKAGE}/forward.skel"

tar cz --exclude="*~" --exclude=".*.swp" -f "$PUBLISHNAME" "$PACKAGE"
mv "$PUBLISHNAME" ..
cd ..
rm -rf .tempDist
