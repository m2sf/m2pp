#!/bin/bash
echo "*** M2PP build configuration script for Unix/POSIX ***"
#
# compiler menu
#
echo ""
echo "Compiler Selection"
PS3="Modula-2 compiler: "
select compiler in \
  "GNU Modula-2" "p1 Modula-2" "XDS Modula-2" "generic PIM compiler" Quit
do
  case $compiler in
    "GNU Modula-2")
      compilerID="gm2"
      break
      ;;
    "p1 Modula-2")
      compilerID="p1"
      break
      ;;
    "XDS Modula-2")
      compilerID="xds"
      break
      ;;
    "generic PIM compiler")
      compilerID="pim"
      break
      ;;
    Quit)
      exit
      ;;
  esac
done
#
# io-library menu
#
echo ""
echo "I/O Library Selection"
PS3="I/O library: "
#
# GM2
#
if [ "$compilerID" = "gm2" ]
then
  select iolib in \
    "POSIX I/O library" "ISO I/O library" "PIM I/O library" Quit
  do
    case $iolib in
      "POSIX I/O library")
        iolibID="posix"
        break
        ;;
      "ISO I/O library")
        iolibID="iso"
        break
        ;;
      "PIM I/O library")
        iolibID="pim"
        break
        ;;
      Quit)
        exit
        ;;
    esac
  done
#
# p1 and XDS
#
elif [ "$compilerID" = "p1" ] || [ "$compilerID" = "xds" ]
then
  select iolib in \
    "POSIX" "ISO" Quit
  do
    case $iolib in
      "POSIX I/O library")
        iolibID="posix"
        break
        ;;
      "ISO I/O library")
        iolibID="iso"
        break
        ;;
      Quit)
        exit
        ;;
    esac
  done
#
# PIM
#
else
  iolibID="pim"
fi
#
# memory model menu
#
echo ""
echo "Bitwidths of CARDINAL/LONGINT"
PS3="Memory model: "
select mm in \
  "16/16 bits" "16/32 bits" "32/32 bits" "32/64 bits" "64/64 bits" Quit
do
  case $mm in
    "16/16 bits")
      hashlibID="cardinal"
      break
      ;;
    "16/32 bits")
      hashlibID="longint"
      break
      ;;
    "32/32 bits")
      hashlibID="cardinal"
      break
      ;;
    "32/64 bits")
      hashlibID="cardinal"
      break
      ;;
    "64/64 bits")
      hashlibID="cardinal"
      break
      ;;
    Quit)
      exit
      ;;
  esac
done

echo ""
echo "Selected build configuration"
echo "Compiler     : $compiler ($compilerID)"
echo "I/O library  : $iolib ($iolibID)"
echo "Memory model : $mm ($hashlibID)"

# TO DO #

# END OF FILE