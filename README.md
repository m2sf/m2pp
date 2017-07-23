# m2pp

[![Join the chat at https://gitter.im/modula-2/Lobby](https://badges.gitter.im/modula-2/Lobby.svg)](https://gitter.im/modula-2/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Modula-2 Preprocessor

M2PP is a simple preprocessor for the Modula-2 language.

It generates Modula-2 source files from generic Modula-2 source file templates. Its primary purpose is to provide a means to write and maintain dialect independent code that is portable across different Modula-2 dialects. However, it can also be used for generic programming where the Modula-2 dialect or compiler does not support generics.

M2PP is itself portable across dialects and compilers. Where necessary, adaptation libraries are provided. Thus far the following compilers are specifically supported:

* [ACK Modula-2](http://tack.sourceforge.net/olddocs/m2ref.html)
* [ADW (formerly Stony Brook) Modula-2](https://www.modula2.org/adwm2/)
* [GNU Modula-2](http://nongnu.org/gm2/homepage.html)
* [Garden's Point Modula-2](https://github.com/k-john-gough/gpmclr)
* [MOCKA Modula-2](http://www.info.uni-karlsruhe.de/projects.php/id=37&lang=en)
* [Modulaware](https://www.modulaware.com/mwcvms.htm)
* [p1 Modula-2](http://modula2.awiedemann.de/)
* [Ulm's Modula-2 System](http://www.mathematik.uni-ulm.de/modula/)
* [XDS](https://www.excelsior-usa.com/xds.html)

Further, any Modula-2 compiler that supports PIM3/4 and includes modules `FileSystem` and `Terminal` will be able to compile M2PP without problems, for example:
* FST Modula-2
* Logitech Modula-2
* M2F Modula-2
* TERRA Modula-2

Adaptation libraries for the [Aglet](http://aglet.web.runbox.net/) and [Clarion (formerly TopSpeed)](http://www.softvelocity.com/) Modula-2 compilers are still missing and shall be added later (contributors welcome).

For more details please visit the project wiki at the URL:

https://github.com/m2sf/m2pp/wiki

+++
