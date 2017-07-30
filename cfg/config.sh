#!/bin/bash
# config.sh * Copyright (c) 2017 Modula-2 Software Foundation
# usage:
#  config [clean] [--test | -t]

# ---------------------------------------------------------------------------
# main script
# ---------------------------------------------------------------------------
#
function main {
  echo "*** M2PP build configuration script for Unix/POSIX ***"
  
  checkArgs $@
    
  if [ "$clean" = "true" ]; then
    querySourcePath
    cleanFiles
  else
    dialectMenu
    compilerMenu
    iolibMenu
    memModelMenu
    querySourcePath
    getConfirmation
    copyFiles
    genBuildInfo
  fi
} # end main


# ---------------------------------------------------------------------------
# check arguments
# ---------------------------------------------------------------------------
# sets global variables test and clean
#
function checkArgs {
  if [ "$1" = "clean" ]; then
    clean=true
    
    if [ "$2" = "-t" ] || [ "$2" = "--test" ]; then
      test=true
    else
      test=false
    fi
  elif [ "$1" = "-t" ] || [ "$1" = "--test" ]; then
    clean=false
    test=true
    
    if [ "$2" != "" ]; then
      echo ""
      echo "unknown argument $2 ignored."
    fi
  else
    clean=false
    test=false
  fi
  
  if [ "$test" = "true" ]; then
    echo ""
    if [ "$clean" = "true" ]; then
      echo "running in test mode, no files will be deleted."
    else
      echo "running in test mode, no files will be copied nor deleted."
    fi
  fi
} # end checkArgs


# ---------------------------------------------------------------------------
# dialect menu
# ---------------------------------------------------------------------------
# sets global variables dialect and dialectID
#
function dialectMenu {
  echo ""
  echo "Dialect Selection"
  PS3="Modula-2 dialect: "
  select dialect in "ISO Modula-2" "PIM Modula-2" Quit
  do
    case $dialect in
      "ISO Modula-2")
        dialectID="iso"
        break;;
      "PIM Modula-2")
        dialectID="pim"
        break;;
      Quit)
        exit;;
    esac
  done
} # end dialectMenu


# ---------------------------------------------------------------------------
# compiler menu
# ---------------------------------------------------------------------------
# sets global variables compiler, compilerID and needsPosixShim
#
function compilerMenu {
  echo ""
  echo "Compiler Selection"
  PS3="Modula-2 compiler: "
  
  if [ "$dialectID" = "iso" ]; then
    isoCompilerMenu
  elif [ "$dialectID" = "pim" ]; then
    pimCompilerMenu
  else
    echo ""
    echo "internal error: invalid dialectID"
    exit
  fi
} # end compilerMenu


# ---------------------------------------------------------------------------
# ISO compiler selection
# ---------------------------------------------------------------------------
# sets global variables compiler, compilerID and needsPosixShim
#
function isoCompilerMenu {
  needsPosixShim=false
  select compiler in \
    "GNU Modula-2" "GPM Modula-2" "p1 Modula-2" "XDS Modula-2" Quit
  do
    case $compiler in
      "GNU Modula-2")
        compilerID="gm2"
        break;;
      "GPM Modula-2")
        compilerID="gpm"
        break;;
      "p1 Modula-2")
        compilerID="p1"
        break;;
      "XDS Modula-2")
        compilerID="xds"
        break;;
      Quit)
        exit;;
    esac
  done
} # end isoCompilerMenu


# ---------------------------------------------------------------------------
# PIM compiler selection
# ---------------------------------------------------------------------------
# sets global variables compiler, compilerID and needsPosixShim
#
function pimCompilerMenu {
  needsPosixShim=false
  select compiler in \
    "ACK Modula-2" "GNU Modula-2" "MOCKA Modula-2" "Ulm's Modula-2" \
    "generic PIM compiler" Quit
  do
    case $compiler in
      "ACK Modula-2")
        compilerID="ack"
        needsPosixShim=true
        break;;
      "GNU Modula-2")
        compilerID="gm2"
        break;;
      "MOCKA Modula-2")
        compilerID="mocka"
        needsPosixShim=true
        break;;
      "Ulm's Modula-2")
        compilerID="ulm"
        break;;
      "generic PIM compiler")
        compilerID="pim"
        break;;
      Quit)
        exit;;
    esac
  done
} # end pimCompilerMenu


# ---------------------------------------------------------------------------
# I/O library menu
# ---------------------------------------------------------------------------
# sets global variables iolib and iolibID
#
function iolibMenu {
  echo ""
  echo "I/O Library Selection"
  PS3="I/O library: "

  if [ "$dialectID" = "iso" ]; then
    isoIolibMenu
  elif [ "$dialectID" = "pim" ]; then
    pimIolibMenu
  else
    echo ""
    echo "internal error: invalid dialectID"
    exit
  fi
} # end iolibMenu


# ---------------------------------------------------------------------------
# ISO compiler I/O library selection
# ---------------------------------------------------------------------------
# sets global variables iolib and iolibID
#
function isoIolibMenu {
  if [ "$compilerID" = "gpm" ]; then
    iolib="vendor library"
    iolibID="gpm"
    echo "$iolib"
  else # posix or iso
    select iolib in "POSIX I/O library" "ISO I/O library" Quit
    do
      case $iolib in
        "POSIX I/O library")
          iolibID="posix"
          break;;
        "ISO I/O library")
          iolibID="iso"
          break;;
        Quit)
          exit;;
      esac
    done
  fi
} # end isoIolibMenu


# ---------------------------------------------------------------------------
# PIM compiler I/O library selection
# ---------------------------------------------------------------------------
# sets global variables iolib and iolibID
#
function pimIolibMenu {
  if [ "$compilerID" = "ack" ] || [ "$compilerID" = "mocka" ]; then
    # posix only
    iolib="POSIX I/O library"
    iolibID="posix"
    echo "$iolib"
  elif [ "$compilerID" = "ulm" ]; then
    # vendor only
    iolib="vendor library"
    iolibID="ulm"
    echo "$iolib"
  else
    # posix or pim
    select iolib in "POSIX I/O library" "PIM I/O library" Quit
    do
      case $iolib in
        "POSIX I/O library")
          iolibID="posix"
          break;;
        "PIM I/O library")
          iolibID="pim"
          break;;
        Quit)
          exit;;
      esac
    done
  fi
} # end pimIolibMenu


# ---------------------------------------------------------------------------
# memory model menu
# ---------------------------------------------------------------------------
# sets global variables mm and mmID
#
function memModelMenu {
  echo ""
  echo "Bitwidths of CARDINAL/LONGINT"
  PS3="Memory model: "
  
  select mm in \
    "16/16 bits" "16/32 bits" "32/32 bits" "32/64 bits" "64/64 bits" Quit
  do
    case $mm in
      "16/16 bits")
        mmID="cardinal"
        break;;
      "16/32 bits")
        mmID="longint"
        break;;
      "32/32 bits")
        mmID="cardinal"
        break;;
      "32/64 bits")
        mmID="cardinal"
        break;;
      "64/64 bits")
        mmID="cardinal"
        break;;
      Quit)
        exit;;
    esac
  done
} # end memModelMenu


# ---------------------------------------------------------------------------
# M2PP source path query
# ---------------------------------------------------------------------------
# sets global variable srcpath
#
function querySourcePath {
  echo ""
  read -rp "Path of M2PP src directory: " srcpath
  # check path for leading ~, expand if present
  if [ "${srcpath: 1}" != "~" ]; then
    srcpath="$HOME${srcpath:1}"
  fi
  
  # check path for final /, add one if missing
  if [ "${srcpath:(-1)}" != "/" ]; then
    srcpath="$srcpath/"
  fi
  
  # check if directory at path exists
  if [ ! -d "$srcpath" ]; then
    echo "directory $srcpath does not exist"
    exit
  fi
} # end querySourcePath


# ---------------------------------------------------------------------------
# print summary and get user confirmation
# ---------------------------------------------------------------------------
# exits unless user confirmation is obtained
#
function getConfirmation {
  echo ""
  echo "Selected build configuration"
  echo "Dialect       : $dialect ($dialectID)"
  echo "Compiler      : $compiler ($compilerID)"
  echo "I/O library   : $iolib ($iolibID)"
  echo "Memory model  : $mm ($mmID)"
  echo "M2PP src path : $srcpath"
  echo ""
  read -rp "Are these details correct? (y/n) : " confirm
  if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    exit
  fi
} # end getConfirmation


# ---------------------------------------------------------------------------
# copy source files
# ---------------------------------------------------------------------------
# copies and renames source files depending on selected configuration
#
function copyFiles {
  echo ""
  echo Copying source files corresponding to selected build configuration ...
  echo ""
  
  # module Infile
  copy "${srcpath}Infile.${dialectID}.def" "${srcpath}Infile.def"
  
  # module Outfile
  copy "${srcpath}Outfile.${dialectID}.def" "${srcpath}Outfile.def"
  
  # module Proc
  copy "${srcpath}Proc.${dialectID}.def" "${srcpath}Proc.def"
  
  # module Size
  copy "${srcpath}Size.${mmID}.def" "${srcpath}Size.def"
  
  # module String
  copy "${srcpath}String.${dialectID}.def" "${srcpath}String.def"
  copy "${srcpath}imp/String.${dialectID}.mod" "${srcpath}imp/String.mod"
  
  # module Terminal
  if [ "$iolibID" = "iso" ] || [ "$iolibID" = "posix" ]; then
    copy "${srcpath}Terminal.nonpim.def" "${srcpath}Terminal.def"
    copy "${srcpath}imp/Terminal.${iolibID}.mod" "${srcpath}imp/Terminal.mod"
  else
    remove "${srcpath}Terminal.def"
    remove "${srcpath}imp/Terminal.mod"
  fi
  
  # module BasicFileIO
  copy "${srcpath}imp/BasicFileIO/BasicFileIO.${iolibID}.mod" \
    "${srcpath}imp/BasicFileIO.mod"
  
  # module BasicFileSys
  if [ "$iolibID" = "pim" ] || [ "$iolibID" = "posix" ]; then
    copy \
      "${srcpath}imp/BasicFileSys/BasicFileSys.${iolibID}.mod" \
      "${srcpath}imp/BasicFileSys.mod"
  else
    copy \
      "${srcpath}imp/BasicFileSys/BasicFileSys.${compilerID}.mod" \
      "${srcpath}imp/BasicFileSys.mod"
  fi
  
  # posix shim libraries
  if [ "$needsPosixShim" = "true" ]; then
    echo "${compiler} requires POSIX shim libraries"
    echo ""
    copy "${srcpath}posix/stdio.shim.def" "${srcpath}stdio.def"
    copy "${srcpath}imp/posix/stdio.shim.mod" "${srcpath}imp/stdio.mod"
    copy "${srcpath}posix/unistd.shim.def" "${srcpath}unistd.def"
    copy "${srcpath}imp/posix/unistd.shim.mod" "${srcpath}imp/unistd.mod"
  fi
  
  # foreign interface modules stdio and unistd
  if [ "$iolibID" = "posix" ] || [ "$compilerID" = "p1" ]; then
    if [ "$compilerID" = "gm2" ]; then
      copy "${srcpath}posix/stdio.${compilerID}.${dialectID}.def" \
        "${srcpath}stdio.def"
      copy "${srcpath}posix/unistd.${compilerID}.def" \
        "${srcpath}unistd.def"
    elif [ "$needsPosixShim" = "true" ]; then
      copy "${srcpath}posix/stdio0.${compilerID}.def" "${srcpath}stdio0.def"
      copy "${srcpath}posix/unistd0.${compilerID}.def" "${srcpath}unistd0.def"
    else
      copy "${srcpath}posix/stdio.${compilerID}.def" "${srcpath}stdio.def"
      copy "${srcpath}posix/unistd.${compilerID}.def" "${srcpath}unistd.def"
    fi
  else
    remove "${srcpath}stdio.def"
    remove "${srcpath}stdio0.def"
    remove "${srcpath}unistd.def"
    remove "${srcpath}unistd0.def"
    remove "${srcpath}imp/stdio.mod"
    remove "${srcpath}imp/unistd.mod"
  fi
  
  echo "Build configuration completed."
} # end copyFiles


# ---------------------------------------------------------------------------
# copy file
# ---------------------------------------------------------------------------
# copies first argument to second argument, prints info
#
function copy {
  echo "copying $1"
  echo "     to $2"
  if [ "$test" != "true" ]; then
    cp $1 $2
  fi
  echo ""
} # end copy


# ---------------------------------------------------------------------------
# clean files
# ---------------------------------------------------------------------------
#
function cleanFiles {
  echo ""
    
  # module Infile
  remove "${srcpath}Infile.def"
  
  # module Outfile
  remove "${srcpath}Outfile.def"
  
  # module Proc
  remove "${srcpath}Proc.def"
  
  # module Size
  remove "${srcpath}Size.def"
  
  # module String
  remove "${srcpath}String.def"
  remove "${srcpath}imp/String.mod"
  
  # module Terminal
  remove "${srcpath}Terminal.def"
  remove "${srcpath}imp/Terminal.mod"
  
  # module BasicFileIO
  remove "${srcpath}imp/BasicFileIO.mod"
  
  # module BasicFileSys
  remove "${srcpath}imp/BasicFileSys.mod"
  
  # posix interfaces and shim libraries
  remove "${srcpath}stdio.def"
  remove "${srcpath}stdio0.def"
  remove "${srcpath}unistd.def"
  remove "${srcpath}unistd0.def"
  remove "${srcpath}imp/stdio.mod"
  remove "${srcpath}imp/unistd.mod"
  
  remove "${srcpath}BuildInfo.def"
  
  echo "Clean configuration completed."
} # end clean


# ---------------------------------------------------------------------------
# remove file
# ---------------------------------------------------------------------------
# removes file at path $1, prints info
#
function remove {
  if [ -f $1 ]; then
    echo "removing $1"
    if [ "$test" != "true" ]; then
      rm $1
    fi
    echo ""
  fi
} # end remove


# ---------------------------------------------------------------------------
# generate build info file
# ---------------------------------------------------------------------------
# expands template BuildInfo.gen.def with build configuration parameters
#
function genBuildInfo {
  local osname="$(uname -rs)"
  local hardware="$(uname -m)"
  local platform="${osname} (${hardware})"
  local sub1="s|##platform##|\"${platform}\"|;"
  local sub2="s|##dialect##|\"${dialect}\"|;"
  local sub3="s|##compiler##|\"${compiler}\"|;"
  local sub4="s|##iolib##|\"${iolib}\"|;"
  local sub5="s|##mm##|\"${mm}\"|;"
  sed -e "${sub1}${sub2}${sub3}${sub4}${sub5}" \
    "${srcpath}templates/BuildInfo.gen.def" > "${srcpath}BuildInfo.def"
} # end genBuildInfo


# ---------------------------------------------------------------------------
# run main script
# ---------------------------------------------------------------------------
#
main "$@"

# END OF FILE