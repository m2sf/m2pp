REM launch script for m2pp
echo %* > m2ppargs.tmp
m2pp-na
del m2ppargs.tmp
