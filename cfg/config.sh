#!/bin/bash
echo "*** M2PP build configuration script for Unix/POSIX ***"
#
# compiler menu
#
echo "[Compiler Selection]"
PS3="Modula-2 compiler: "
select option in "GM2" "p1" "XDS" "any PIM compiler" Quit
do
  case $option in
    "GM2")
      echo GNU Modula-2
      break
      ;;
    "p1")
      echo p1 Modula-2
      break
      ;;
    "XDS")
      echo XDS Modula-2;
      break
      ;;
    "any PIM compiler")
      echo generic PIM Modula-2
      break
      ;;
    Quit)
      exit
      ;;
  esac
done
#
# library menu
#
echo "[I/O Library Selection]"
PS3="I/O library: "
select option in "POSIX" "ISO" "PIM" Quit
do
  case $option in
    "POSIX")
      echo POSIX
      break
      ;;
    "ISO")
      echo ISO
      break
      ;;
    "PIM")
      echo PIM
      break
      ;;
    Quit)
      exit
      ;;
  esac
done
#
# memory model menu
#
echo "[Bitwidths of CARDINAL/LONGINT]"
PS3="Memory model: "
select option in "16/16" "16/32" "32/32" "32/64" "64/64" Quit
do
  case $option in
    "16/16")
      echo "16/16"
      break
      ;;
    "16/32")
      echo "16/32"
      break
      ;;
    "32/32")
      echo "32/32"
      break
      ;;
    "32/64")
      echo "32/64"
      break
      ;;
    "64/64")
      echo "64/64"
      break
      ;;
    Quit)
      exit
      ;;
  esac
done

# TO DO #

# END OF FILE