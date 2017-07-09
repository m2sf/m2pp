! m2pp launch script for OpenVMS
open/write outfile m2ppargs.tmp
if p1 .nes. "" then write outfile p1
if p2 .nes. "" then write outfile p2
if p3 .nes. "" then write outfile p3
if p4 .nes. "" then write outfile p4
if p5 .nes. "" then write outfile p5
if p6 .nes. "" then write outfile p6
if p7 .nes. "" then write outfile p7
if p8 .nes. "" then write outfile p8
close outfile
mcr m2pp.exe
delete m2ppargs.tmp;*
