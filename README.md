# root-encrypt
Code for blog article
[Automatically encrypt root mails sent off-site](https://michael-herbst.com/automatically-encrypt-root-mails.html).

## Required programs and packages
- gnupg
- mime-construct
- some mail delivery agent / message transfer agent (recommended: postfix)

It is important that the agent reads `/etc/aliases` and `.forward` files and
understands delivery to a command.

Note, that nullmailer is not suitable. Any other agents but postfix
(such as exim) were not tested.

## Prepare your installation package
Before installation the files in root-encrypt need to be bundled with one of
your public keys. This is the key that will be used to encrypt the mail sent off
as root. You need to know the long key id for this key (i.e. the 8-byte version
and not the usual 4-byte one). One way to obtain this is to run
```
gpg --fingerprint --list-key <short key id or name>
```
and note the last four 2-byte blocks of the fingerprint.

Now run `./bundle.sh` to enter this information and create the install package.
It is assumed that on the local computer the key you selected for encryption is
present and trusted.

If all goes well you end up with a tarball <date>-root-encrypt.tar.gz which you
can transfer to your servers, unpack and `./install.sh`.

## Advanced options
If you don't want to specify your email address and key id each time you run
`./bundle.sh` you can drop your email address in a file called `email` and the
key id in a file called `keyid`.
