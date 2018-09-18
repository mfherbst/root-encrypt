#!/bin/bash
# read message on stdin and send it to $1 using long keyid $2
#
#####################################################################
# Licence:
#
# (C) 2015 Michael F. Herbst <info@michael-herbst.com>
#
# encrypt_mail.sh is free software: you can redistribute it and/or modify
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

GPGOPTIONS="--display-charset utf-8 --no-auto-key-locate \
	--personal-cipher-preferences \"AES256 AES192 AES\" \
	--personal-digest-preferences \"SHA512 SHA384 SHA256\" \
	--personal-compress-preferences \"ZLIB BZIP2 ZIP\""

#####################################################################

dump_mail(){
	#Take a message on stdin and add content to message queue

	[ ! -d "$HOME/tmp/" ] && mkdir "$HOME/tmp/"
	local TMP=`mktemp --tmpdir=$HOME/tmp/`
	chmod 600 $TMP
	cat >$TMP
}

get_mails() {
	#get all messages in the queue and produce a list
	ls -tr $HOME/tmp/
}

send_mail() {
	#$1: file containing the queued mail

	local MAILFILE="$HOME/tmp/$1"
	[ ! -f "$MAILFILE" ] && return 0

	local SUBJECT=
	SUBJECT=`< "$MAILFILE" awk '$1 == "Subject:" { sub(/^Subject: /,""); print $0; exit }'` || return 1
	[ -z "$SUBJECT" ] && SUBJECT="encrypted"

	[ ! -f "$MAILFILE" ] && return 0
	< "$MAILFILE" eval gpg --batch --quiet --armor --recipient "$LONGKEYID" \
			--trusted-key "$LONGKEYID" $GPGOPTIONS  --encrypt \
		| eval mime-construct --to "$TO" --subject "'$SUBJECT'" \
			--multipart "'multipart/encrypted; protocol=\"application/pgp-encrypted\"'" \
			--type "application/pgp-encrypted" --string "'Version: 1'" --file -

	[ "$?" != "0" ] && return 1
	return 0
}

remove_mail() {
	#$1: file containing the queued mail
	[ ! -f "$HOME/tmp/$1" ] && return 0
	rm "$HOME/tmp/$1"
}

#####################################################################

TO="$1"			#e.g. blubb@blubb.bb
LONGKEYID="$2"		#e.g. 0000DEADBEAF0000

if ! echo "$TO" | grep -q "@.*\."; then
	echo "Please provide a valid email address as first argument."
	exit 1
fi

if ! echo "$LONGKEYID" | grep -qE "^[a-fA-F0-9]{16}$"; then
	echo "Please provide a valid long key id as second argument."
	exit 1
fi

dump_mail	#dump this message and add to queue of messages

# run over all messages in the queue
# (usually there is only one message in there, namely the one we just
#  added, but if there is a power outage or some other problem, things
#  might be different)

for mail in $(get_mails); do
	#send mail and only remove mail if it was successful.
	send_mail "$mail" && remove_mail "$mail"
done
exit 0
