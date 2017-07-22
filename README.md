# m2pp

[![Join the chat at https://gitter.im/modula-2/Lobby](https://badges.gitter.im/modula-2/Lobby.svg)](https://gitter.im/modula-2/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Modula-2 Preprocessor

M2PP is a simple preprocessor for the Modula-2 language.

It generates Modula-2 source files from generic Modula-2 source file templates. Its primary purpose is to provide a means to write and maintain dialect independent code that is portable across different Modula-2 dialects. However, it can also be used for generic programming where the Modula-2 dialect or compiler does not support generics.

M2PP is itself portable across dialects and compilers. Where necessary, adaptation libraries are provided. Thus far specifically supported compilers are [ACK](http://tack.sourceforge.net/olddocs/m2ref.html), [ADW](https://www.modula2.org/adwm2/), [GM2](http://nongnu.org/gm2/homepage.html), [MOCKA](http://www.info.uni-karlsruhe.de/projects.php/id=37&lang=en), [Modulaware](https://www.modulaware.com/mwcvms.htm), [p1](http://modula2.awiedemann.de/) and [XDS](https://www.excelsior-usa.com/xds.html). In addition, PIM compilers that include modules `Terminal` and `FileSystem` should be able to compile M2PP without problems. Adaptation libraries for [Aglet](http://aglet.web.runbox.net/), [Clarion](http://www.softvelocity.com/) and [GPM](https://github.com/k-john-gough/gpmclr) will be added (contributors welcome).

For more details please visit the project wiki at the URL:

https://github.com/m2sf/m2pp/wiki

+++
