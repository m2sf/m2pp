#!/bin/bash
echo "*** M2PP build configuration script for Unix/POSIX ***"
#
# ---------------------------------------------------------------------------
# dialect menu
# ---------------------------------------------------------------------------
echo ""
echo "Dialect Selection"
PS3="Modula-2 dialect: "
select dialect in "ISO Modula-2" "PIM Modula-2" Quit
do
  case $dialect in
    "ISO Modula-2")
      dialectID="iso"
      break
      ;;
    "PIM Modula-2")
      dialectID="pim"
      break
      ;;
    Quit)
      exit
      ;;
  esac
done
#
# ---------------------------------------------------------------------------
# compiler menu
# ---------------------------------------------------------------------------
echo ""
echo "Compiler Selection"
PS3="Modula-2 compiler: "
#
# ---------------------------------------------------------------------------
# ISO compiler selection
# ---------------------------------------------------------------------------
if [ "$dialectID" = "iso" ]
then
  select compiler in "GNU Modula-2" "p1 Modula-2" "XDS Modula-2" Quit
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
      Quit)
        exit
        ;;
    esac
  done
#
# ---------------------------------------------------------------------------
# PIM compiler selection
# ---------------------------------------------------------------------------
elif [ "$dialectID" = "pim" ]
then
  select compiler in "GNU Modula-2" "generic PIM compiler" Quit
  do
    case $compiler in
      "GNU Modula-2")
        compilerID="gm2"
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
fi
#
# ---------------------------------------------------------------------------
# io-library menu
# ---------------------------------------------------------------------------
echo ""
echo "I/O Library Selection"
PS3="I/O library: "
#
# ---------------------------------------------------------------------------
# ISO io-library selection
# ---------------------------------------------------------------------------
if [ "$dialectID" = "iso" ]
then
  select iolib in "POSIX I/O library" "ISO I/O library" Quit
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
# ---------------------------------------------------------------------------
# PIM io-library selection
# ---------------------------------------------------------------------------
elif [ "$dialectID" = "pim" ]
then
  select iolib in "POSIX I/O library" "PIM I/O library" Quit
  do
    case $iolib in
      "POSIX I/O library")
        iolibID="posix"
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
fi
#
# ---------------------------------------------------------------------------
# memory model menu
# ---------------------------------------------------------------------------
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
#
# ---------------------------------------------------------------------------
# m2pp src path
# ---------------------------------------------------------------------------
echo ""
read -rp "Path of M2PP src directory: " srcpath
# check path for leading ~, expand if present
if [ "${srcpath: 1}" != "~" ]
then
  srcpath="$HOME${srcpath:1}"
fi
#
# check path for final /, add one if missing
if [ "${srcpath:(-1)}" != "/" ]
then
  srcpath="$srcpath/"
fi
#
# check if directory at path exists
if [ ! -d "$srcpath" ]
then
  echo "directory $srcpath does not exist"
  exit
fi
#
# ---------------------------------------------------------------------------
# print summary
# ---------------------------------------------------------------------------
echo ""
echo "Selected build configuration"
echo "Dialect       : $dialect ($dialectID)"
echo "Compiler      : $compiler ($compilerID)"
echo "I/O library   : $iolib ($iolibID)"
echo "Memory model  : $mm ($hashlibID)"
echo "M2PP src path : $srcpath"
#
# ---------------------------------------------------------------------------
# user confirmation
# ---------------------------------------------------------------------------
echo ""
read -rp "Are these details correct? (y/n) : " confirm
if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]
then
  exit
fi
#
# ---------------------------------------------------------------------------
# copy source files
# ---------------------------------------------------------------------------
echo ""
echo Copying source files corresponding to selected build configuration ...
echo ""

# module Hash
echo copying "${srcpath}Hash.${hashlibID}.def"
echo  to "${srcpath}Hash.def"
#cp "${srcpath}Hash.${hashlibID}.def" "${srcpath}Hash.def"
echo copying "${srcpath}imp/Hash.${hashlibID}.mod"
echo  to "${srcpath}imp/Hash.mod"
#cp "${srcpath}imp/Hash.${hashlibID}.mod" "${srcpath}/imp/Hash.mod"

# module Infile
echo copying "${srcpath}Infile.${dialectID}.def"
echo  to "${srcpath}Infile.def"
#cp "${srcpath}Infile.${dialectID}.def" "${srcpath}Infile.def"

# module Outfile
echo copying "${srcpath}Outfile.${dialectID}.def"
echo  to "${srcpath}Outfile.def"
#cp "${srcpath}Outfile.${dialectID}.def" "${srcpath}Outfile.def"

# module String
echo copying "${srcpath}String.${dialectID}.def"
echo  to "${srcpath}String.def"
#cp "${srcpath}String.${dialectID}.def" "${srcpath}String.def"
echo copying "${srcpath}imp/String.${dialectID}.mod"
echo  to "${srcpath}imp/String.mod"
#cp "${srcpath}imp/String.${dialectID}.def" "${srcpath}imp/String.mod"

# module Terminal
if [ "$dialectID" = "iso" ]
then
  echo copying "${srcpath}Terminal.iso.def"
  echo  to "${srcpath}Terminal.def"
#cp "${srcpath}Terminal.iso.def" "${srcpath}Terminal.def"
  echo copying "${srcpath}imp/Terminal.iso.mod"
  echo  to "${srcpath}imp/Terminal.mod"
#cp "${srcpath}imp/Terminal.iso.mod" "${srcpath}imp/Terminal.mod"
else
  if [ -f "${srcpath}Terminal.def" ]
  then
    echo removing "${srcpath}Terminal.def"
    # rm "${srcpath}Terminal.def"
  fi
  if [ -f "${srcpath}imp/Terminal.mod" ]
  then
    echo removing "${srcpath}imp/Terminal.mod"
    # rm "${srcpath}imp/Terminal.mod"
  fi
fi

# module BasicFileIO
echo copying "${srcpath}imp/BasicFileIO/BasicFileIO.${iolibID}.mod"
echo  to "${srcpath}imp/BasicFileIO.mod"
#cp "${srcpath}imp/BasicFileIO/BasicFileIO.${iolibID}.mod"
#\  "${srcpath}imp/BasicFileIO.mod"

# module FileSystemAdapter
if [ "$iolibID" = "iso" ]
then
  echo copying \
    "${srcpath}imp/FileSystemAdapter/FileSystemAdapter.${compilerID}.mod"
  echo  to "${srcpath}imp/FileSystemAdapter.mod"
#cp "${srcpath}imp/BasicFileIO/BasicFileIO.${iolibID}.mod"
#\  "${srcpath}imp/BasicFileIO.mod"
else
  echo copying \
    "${srcpath}imp/FileSystemAdapter/FileSystemAdapter.${iolibID}.mod"
  echo  to "${srcpath}imp/FileSystemAdapter.mod"
#cp "${srcpath}imp/BasicFileIO/BasicFileIO.${iolibID}.mod"
#\  "${srcpath}imp/BasicFileIO.mod"
fi

# foreign module stdio
if [ "$iolibID" = "posix" ] || [ "$compilerID" = "p1" ]
then
  echo copying "${srcpath}posix/stdio.${compilerID}.def"
  echo  to "${srcpath}stdio.def"
#cp "${srcpath}posix/stdio.${compilerID}.def" "${srcpath}/stdio.def"
else
  if [ -f "${srcpath}stdio.def" ]
  then
    echo removing "${srcpath}stdio.def"
    # rm "${srcpath}stdio.def"
  fi
fi

echo ""
echo "Build configuration completed."

# END OF FILE