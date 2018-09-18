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

#####################################

assertions() {
	if ! which mime-construct > /dev/null; then
		echo "Please install mime-construct" >&2
		exit 1
	fi
	return 0
}

create_user() {
	adduser --system --group --home "${TARGETDIR}" root-encrypt || return 1
	chown -R root-encrypt:root-encrypt "${TARGETDIR}" || return 1
	chmod 700 "${TARGETDIR}"
}

copy_files() {
	install encrypt_mail.sh -m 755 -g root-encrypt -o root-encrypt ${TARGETDIR} || return 1

	touch ${TARGETDIR}/.forward || return 1
	chmod 600 ${TARGETDIR}/.forward || return 1
	chown root-encrypt:root-encrypt ${TARGETDIR}/.forward || return 1

	< forward.skel sed "s#TTAARRGGEETT#${TARGETDIR}#" > ${TARGETDIR}/.forward
}

import_gnupg_key() {
	su -s /bin/sh root-encrypt -c "gpg --import key.asc"
}

bend_aliases() {
	< /etc/aliases sed '/^root:/d; $a root: root-encrypt' > /etc/aliases.new || return 1
	mv /etc/aliases /etc/aliases.old || return 1
	mv /etc/aliases.new /etc/aliases || return 1
	
	# update aliases.db if neccessary:
	[ -f /etc/aliases.db ] && postalias /etc/aliases 

	# move a root .forward file away if it exists
	if [ -f /root/.forward ]; then
		echo "moving /root/.forward to /root/.forward.old"
		mv /root/.forward /root/.forward.old || return 1
	fi
	return 0
}

assertions

if ! create_user; then
	echo "Error creating root-encrypt user" >&2
	exit 1
fi

if ! copy_files; then
	echo "Error copying files to ${TARGETDIR}" >&2
	exit 1
fi

if ! import_gnupg_key; then
	echo "Error importing key into root-encrypt keydir" >&2
	exit 1
fi

if ! bend_aliases; then
	echo "Error editing /etc/aliases file." >&2
	echo "A backup is kept in /etc/aliases.old." >&2
	echo "Please look at /etc/aliases and /etc/aliases.old and find out what is wrong" >&2
	exit 1
fi

echo "All done"
echo "Note, that the process modified /etc/aliases and moved the original file to /etc/aliases.old."

exit 0
