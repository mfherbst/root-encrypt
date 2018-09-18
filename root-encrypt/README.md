# root-encrypt installation bundle

## Required programs and packages
- gnupg
- mime-construct
- some mail delivery agent / message transfer agent (recommended: postfix)

It is important that the agent reads `/etc/aliases` and `.forward` files and
understands delivery to a command.

Note, that nullmailer is not suitable. Any other agents but postfix
(such as exim) were not tested.

## Installing
To install the package simply run (as root)
```
./install.sh
```

The process will create the new user root-encrypt and make some changes to the system's
`/etc/aliases` file.
Also if a `/root/.forward` file is present it is moved to `/root/.forward.old`
