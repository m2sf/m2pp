### Launch Scripts ###

There is no way to obtain command line arguments in Modula-2 in a dialect independent way,
nor is it even possible to do so in a portable manner across different operating systems.

For this reason M2PP reads its command line arguments from a file called `m2ppargs.tmp`.
A small launch script is therefore required that will echo the command line arguments into
this file, then launch M2PP and delete the temporary file again after M2PP has exited.

This directory contains the launch scripts for different operating systems:

* `m2pp.sh` for the bash shell used on Unix and Unix-like operating systems
* `m2pp.bat` for the command interpreter on Windows, MS-DOS and OS/2

Launch scripts for AmigaOS and OpenVMS will be added in the future.
