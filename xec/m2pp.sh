#!/bin/bash
# launch script for m2pp
echo $@ > m2ppargs.tmp
m2pp-na
rm m2ppargs.tmp
