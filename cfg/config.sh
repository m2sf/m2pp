#!/bin/bash
echo "*** M2PP build configuration script for Unix/POSIX ***"
#
# dialect menu
#
echo "[Compiler Selection]"
PS3="Modula-2 compiler: "
select option in "ADW" "GM2" "p1" "XDS" "any PIM compiler" Quit
do
  case $option in
    "ADW")
      echo ADW Modula-2;;
    "GM2")
      echo GNU Modula-2;;
    "p1")
      echo p1 Modula-2;;
    "XDS")
      echo XDS Modula-2;;
    "any PIM compiler")
      echo generic PIM Modula-2;;
    Quit)
      break;;
  esac
done
#
# CARDINAL size
#
echo "[CARDINAL Size]"
PS3="Size of type CARDINAL: "
select option in "16 bits" "32 bits" "64 bits" Quit
do
  case $option in
    "16 bits")
      echo 16;;
    "32 bits")
      echo 32;;
    "64 bits")
      echo 64;;
    Quit)
      break;;
  esac
done
#
# LONGINT size
#
echo "[LONGINT Size]"
PS3="Size of type LONGINT: "
select option in "16 bits" "32 bits" "64 bits" Quit
do
  case $option in
    "16 bits")
      echo 16;;
    "32 bits")
      echo 32;;
    "64 bits")
      echo 64;;
    Quit)
      break;;
  esac
done

# TO DO #

# END OF FILE