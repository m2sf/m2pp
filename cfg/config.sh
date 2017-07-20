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
      ;;
    "p1")
      echo p1 Modula-2
      ;;
    "XDS")
      echo XDS Modula-2;
      ;;
    "any PIM compiler")
      echo generic PIM Modula-2
      ;;
    Quit)
      break;;
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
      ;;
    "ISO")
      echo ISO
      ;;
    "PIM")
      echo PIM
      ;;
    Quit)
      break;;
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
      ;;
    "16/32")
      echo "16/32"
      ;;
    "32/32")
      echo "32/32"
      ;;
    "32/64")
      echo "32/64"
      ;;
    "64/64")
      echo "64/64"
      ;;
    Quit)
      break;;
  esac
done

# TO DO #

# END OF FILE