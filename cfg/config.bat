@echo off

:: config.bat * Copyright (c) 2017 Modula-2 Software Foundation
:: usage:
:: config [clean] [--test | -t]

:: ---------------------------------------------------------------------------
:: main script
:: ---------------------------------------------------------------------------

:main
echo *** M2PP build configuration script for Unix/POSIX ***

call :checkArgs %*

if %clean% == true (		
	call :querySourcePath 	
	call :cleanFiles				
) else (
	call :dialectMenu				
	call :compilerMenu			
	call :iolibMenu					
	call :memModelMenu			
	call :querySourcePath		
	call :getConfirmation		
	call :copyFiles					
	call :genBuildInfo )
	
EXIT /B 0
	
:: ---------------------------------------------------------------------------
:: check arguments
:: ---------------------------------------------------------------------------
:: sets global variables test and clean
:: ---------------------------------------------------------------------------

:checkArgs
if "%1" == "clean" (
	set clean=true
	
	if "%2" == -t set or_2 = T
	if "%2" == --test set or_2 = T
	
	if "%or_2%" == T (
		set test=true
	) else (
		set test=false
	)
) else (	
	if "%1" == -t set or_1 = T
	if "%1" == --test set or_1 = T
	
	if "%or_1%" == T (
		set clean=false
		set test=true
		
		if NOT $~2 == "" (
			echo.
			echo unknown argument $~2 ignored.
		) 
	) else (
		set clean=false
		set test=false
	)
)		

if %test% == true (
	echo.
	if %clean% == true (
		echo running in test mode, no files will be deleted.
	) else (
		echo running in test mode, no files will be copied or deleted.
	)
)
EXIT /B 0

:: ---------------------------------------------------------------------------
:: dialect menu
:: ---------------------------------------------------------------------------
:: sets global variables dialect and dialectID
:: ---------------------------------------------------------------------------

:dialectMenu
echo.
echo Dialect Section

echo 1) ISO Modula-2
echo 2) PIM Modula-2
echo 3) GPM Modula-2
echo 4) Quit Modula-2 dialect:  
set /p dialect=

if %dialect% == 1 (
	set dialectID=iso
) else (

	if %dialect% == 2 (
		set dialectID=pim
	) else (

		if %dialect% == 3 (
			set dialectID=gpm
		) else (
	
			if %dialect% == 4 (
				EXIT 0
			) else (
		
				echo Invalid input.
				call :dialectMenu
			)
		)
	)
)
	
EXIT /B 0

:: ---------------------------------------------------------------------------
:: compiler menu
:: ---------------------------------------------------------------------------
:: sets global variables compiler, compilerID and needsPosixShim
:: ---------------------------------------------------------------------------

:compilerMenu
echo.
echo Compiler Selection
set PS3=Modula-2 Compiler

if %dialectID% == iso (
	call :isoCompilerMenu
) else (

	if %dialectID% == pim (
		call :pimCompilerMenu
	) else (

		if %dialectID% == gpm (
			call :gpmCompilerMenu
		) else (
	
			echo.
			echo internal error: invalid dialectID
			EXIT 1
		)
	)
)
EXIT /B 0

:: ---------------------------------------------------------------------------
:: ISO compiler selection
:: ---------------------------------------------------------------------------
:: sets global variables compiler, compilerID and needsPosixShim
:: ---------------------------------------------------------------------------

:isoCompilerMenu
set needsPosixShim=false
set iso[1]=adw
set iso[2]=xds

echo 1) ADW Modula-2
echo 2) XDS Modula-2
echo 3) Quit

set /p compiler=Select Compiler: 

if "%compiler%"=="" (
	echo Invalid Input.
	call :isoCompilerMenu
)

if %compiler% LEQ 2  (
call set compilerID=%%iso[%compiler%]%%
) else (

	if %compiler% == 3 (
		EXIT 0
		) else (
		
			echo Invalid input.
			call :isoCompilerMenu
		)
	)
)
EXIT /B 0

:: ---------------------------------------------------------------------------
:: PIM compiler selection
:: ---------------------------------------------------------------------------
:: sets global variables compiler, compilerID and needsPosixShim
:: ---------------------------------------------------------------------------

:pimCompilerMenu
set needsPosixShim=false
set pim[1]=fst
set pim[2]=logitech

echo 1) FST Modula-2
echo 2) Logitech Modula-2
echo 3) Quit

set /p compiler=Select Compiler:

if "%compiler%"=="" (
	echo Invalid Input.
	call :pimCompilerMenu
)

if %compiler% LEQ 2  (
call set compilerID=%%pim[%compiler%]%%
) else (

	if %compiler% == 3 (
		EXIT 0
		) else (
		
			echo Invalid input.
			call :pimCompilerMenu
		)
	)
)
EXIT /B 0

:: ---------------------------------------------------------------------------
:: GPM compiler selection
:: ---------------------------------------------------------------------------
:: sets global variables compiler, compilerID and needsPosixShim
:: ---------------------------------------------------------------------------

:gpmCompilerMenu
set needsPosixShim=false
set pim[1]=gpm

echo 1) GPM Modula-2
echo 2) Quit

set /p compiler=Select Compiler:

if "%compiler%"=="" (
	echo Invalid Input.
	call :gpmCompilerMenu
)

if %compiler% LEQ 1  (
call set compilerID=%%gpm[%compiler%]%%
) else (

	if %compiler% == 2 (
		EXIT 0
		) else (
		
			echo Invalid input.
			call :gpmCompilerMenu
		)
	)
)
EXIT /B 0

:: ---------------------------------------------------------------------------
:: I/O library menu
:: ---------------------------------------------------------------------------
:: sets global variables iolib and iolibID
:: ---------------------------------------------------------------------------
:iolibMenu
echo.
echo I/O Library Selection
set PS3=I/O library

if %dialectID%==iso ( 
	call :isoIolibMenu 
) else (

	if %dialectID%==pim ( 
		call :pimIolibMenu 
	) else (

		if %dialectID%==gpm ( 
			call :gpmIolibMenu 
		) else (
	
		echo.
		echo internal error: invalid dialectID
	)
)
EXIT /B 0

:: ---------------------------------------------------------------------------
:: ISO compiler I/O library selection
:: ---------------------------------------------------------------------------
:: sets global variables iolib and iolibID
:: ---------------------------------------------------------------------------
:isoIolibMenu

setlocal enabledelayedexpansion

echo 1) POSIX I/O library
echo 2) ISO I/O library
echo 3) Quit
set /p "iolib=Select: "

if "!iolib!" == "1" (
	set iolibID=posix
)
 
if "!iolib!" == "2" (
	set iolibID=iso
) 
	
if "!iolib!" == "3" (
	exit
) 
	
if NOT "!iolib!" LEQ "3" (
	echo Invalid Input.
	call :isoIolibMenu
)
:end
EXIT /B 0

:: ---------------------------------------------------------------------------
:: PIM compiler I/O library selection
:: ---------------------------------------------------------------------------
:: sets global variables iolib and iolibID
:: ---------------------------------------------------------------------------
:pimIolibMenu
setlocal enabledelayedexpansion
set "isPosix="

if defined isPosix (
	set iolib=POSIX I/O library
	set iolibID=posix
	echo $iolib
	goto :end
) 

echo 1) POSIX I/O library
echo 2) PIM I/O library
echo 3) Quit
set /p "iolib=Select I/O Library: "

if "!iolib!" == "1" (
	set iolibID=posix
)
 
if "!iolib!" == "2" (
	set iolibID=pim
) 
	
if "!iolib!" == "3" (
	exit
) 
	
if NOT "!iolib!" LEQ "3" (
	echo Invalid Input.
	call :pimIolibMenu
)
:end
EXIT /B 0

:: ---------------------------------------------------------------------------
:: GPM compiler I/O library selection
:: ---------------------------------------------------------------------------
:: sets global variables iolib and iolibID
:: ---------------------------------------------------------------------------
:gpmIolibMenu
setlocal enabledelayedexpansion
set "isPosix="

set iolib=vendor library
set iolibID=gpm
echo $iolib

:end
EXIT /B 0

:: ---------------------------------------------------------------------------
:: memory model menu
:: ---------------------------------------------------------------------------
:: sets global variables mm and mmID
:: ---------------------------------------------------------------------------
:memModelMenu
echo.
echo Bitwidths of CARDINAL/LONGINT

echo 1) 16/16 bits
echo 2) 16/32 bits
echo 3) 32/32 bits
echo 4) 32/64 bits
echo 5) 64/64 bits
echo 6) Quit

set /p "mm=Memory model: "

if "%mm%"=="" (
	echo Invalid Input.
	call :memModelMenu
)

if %mm% LEQ 5  (

	if %mm%==2 (
		set mmID=longint
	) else (
	
		set mmID=cardinal
	)
) else (

	if %mm% == 6 (
		EXIT 0
		) else (
		
			echo Invalid input.
			call :memModelMenu
		)
	)
)
EXIT /B 0

:: ---------------------------------------------------------------------------
:: M2PP source path query
:: ---------------------------------------------------------------------------
:: sets global variable srcpath
:: ---------------------------------------------------------------------------

:querySourcePath
echo.
set /p "srcpath=Path of M2PP src directory: "
set char1=%srcpath:~0,1%
set lastchar=%srcpath:~-1%
echo %char1%
echo %lastchar%
pause

if NOT "%char1%" == "~" (
	call set srcpath=%systemdrive%%homepath%%char1%
)
echo %srcpath%
pause
::changed / to \ because windows uses \ in directories
if NOT "%lastchar%" == "\" ( 
	echo last
	pause
	set "srcpath=%srcpath%\"
)
echo %srcpath%
pause
if NOT EXIST %srcpath% (
	echo directory %srcpath% does not exist
	pause
	exit
)

echo %srcpath%
pause
set /p 
EXIT /B 0

:: ---------------------------------------------------------------------------
:: print summary and get user confirmation
:: ---------------------------------------------------------------------------
:: exits unless user confirmation is obtained
:: ---------------------------------------------------------------------------
:getConfirmation
echo.
echo Selected build configuration
echo Dialect       : %dialectID%
echo Compiler      : %compilerID%
echo I/O library   : %iolibID%
echo Memory model  : %mmID%
echo M2PP src path : %srcpath%
echo.

set /p "confirm=Are these details correct? (y/n) : "

if %confirm%==N ( set confirm=n )
if %confirm%==Y ( set confirm=y )

if %confirm%==n ( exit )

if NOT %confirm%==y (
	echo Invalid Input
	call :getConfirmation
)
EXIT /B 0

:: ---------------------------------------------------------------------------
:: copy source files
:: ---------------------------------------------------------------------------
:: copies and renames source files depending on selected configuration
:: ---------------------------------------------------------------------------
:copyFiles
echo.
echo Copying source files corresponding to selected build configuration ...
echo.
:: module Infile
set sourceFile="%srcpath%Infile.%dialectID%.def"
set destinationFile="%srcpath%Infile.def"
call :copyFile
  
:: module Outfile
set sourceFile="%srcpath%Outfile.%dialectID%.def"
set destinationFile="%srcpath%Outfile.def"
call :copyFile
  
:: module Proc
set sourceFile="%srcpath%Proc.%dialectID%.def"
set destinationFile="%srcpath%Proc.def"
call :copyFile
  
:: module Size
set sourceFile="%srcpath%Size.%mmID%.def"
set destinationFile="%srcpath%Size.def"
call :copyFile
  
:: module String
set sourceFile="%srcpath%String.%dialectID%.def"
set destinationFile="%srcpath%String.def"
call :copyFile
set sourceFile="%srcpath%imp\String.%dialectID%.mod"
set destinationFile="%srcpath%imp\String.mod"
call :copyFile

:: module Terminal
set res=F
if "%iolibID"=="iso" (
	set res=T
)
if "%iolibID"=="posix" (
	set res=T
)
if "%res%"=="T" (
	set sourceFile="%srcpath%Terminal.nonpim.def"
	set destinationFile="%srcpath%Terminal.def"
	call :copyFile
	set sourceFile="%srcpath%imp\Terminal.%iolibID%.mod"
	set destinationFile="%srcpath%imp\Terminal.mod"
	call :copyFile
) else (
	set rmFile="%srcpath%Terminal.def"
	call :remove
	set rmFile="%srcpath%imp\Terminal.mod"
	call :remove
)
  
:: module BasicFileIO
set sourceFile="%srcpath%imp\BasicFileIO\BasicFileIO.%iolibID%.mod"
set destinationFile="%srcpath%imp\BasicFileIO.mod"
call :copyFile

:: module BasicFileSys
set res=F
if "%iolibID"=="pim" (
	set res=T
)
if "%iolibID"=="posix" (
	set res=T
)
if "%res%"=="T" (
	set sourceFile="%srcpath%imp\BasicFileSys\BasicFileSys.%iolibID%.mod"
	set destinationFile="%srcpath%imp\BasicFileSys.mod"
	call :copyFile
) else (
	set sourceFile="%srcpath%imp\BasicFileSys\BasicFileSys.%compilerID%.mod"
	set destinationFile="%srcpath%imp\BasicFileSys.mod"
	call :copyFile
)
  
:: posix shim libraries
if "%needsPosixShim%" == "true" (
    echo "%compiler% requires POSIX shim libraries"
    echo ""
	set sourceFile="%srcpath%posix\stdio.shim.def"
	set destinationFile="%srcpath%stdio.def"
	call :copyFile
	set sourceFile="%srcpath%imp\posix/stdio.shim.mod"
	set destinationFile="%srcpath%imp\stdio.mod"
	call :copyFile
	set sourceFile="%srcpath%posix\unistd.shim.def"
	set destinationFile="%srcpath%unistd.def"
	call :copyFile
	set sourceFile="%srcpath%imp\posix\unistd.shim.mod"
	set destinationFile="%srcpath%imp\unistd.mod"
	call :copyFile
)

:: foreign interface modules stdio and unistd
if "%iolibID%" == "posix" (
    if "%needsPosixShim%" == "true" (
		set sourceFile="%srcpath%posix\stdio0.%compilerID%.def"
		set destinationFile="%srcpath%stdio0.def"
		call :copyFile
		set sourceFile="%srcpath%posix\unistd0.%compilerID%.def"
		set destinationFile="%srcpath%unistd0.def"
		call :copyFile
    ) else (
		set sourceFile="%srcpath%posix\stdio.%compilerID%.def"
		set destinationFile="%srcpath%stdio.def"
		call :copyFile
		set sourceFile="%srcpath%posix\unistd.%compilerID%.def"
		set destinationFile="%srcpath%unistd.def"
		call :copyFile
	)
) else (
	set rmFile="%srcpath%stdio.def"
	call :remove
	set rmFile="%srcpath%stdio0.def"
	call :remove
	set rmFile="%srcpath%unistd.def"
	call :remove
	set rmFile="%srcpath%unistd0.def"
	call :remove
	set rmFile="%srcpath%imp/stdio.mod"
	call :remove
	set rmFile="%srcpath%imp/unistd.mod"
	call :remove
)

	set res=
	set sourceFile=
	set destinationFile=
	set rmFile=

	echo "Build configuration completed."
EXIT /B 0

:: ---------------------------------------------------------------------------
:: copy file
:: ---------------------------------------------------------------------------
:: copies first argument to second argument, prints info
:: ---------------------------------------------------------------------------
:copyFile
echo copying %sourceFile%
echo      to %destinationFile%

if NOT "%test%" == "true" (
	copy %sourceFile% %destinationFile%
)
echo ""
EXIT /B 0

:: ---------------------------------------------------------------------------
:: clean files
:: ---------------------------------------------------------------------------
:cleanFiles
echo.
:: module Infile
set rmFile="%srcpath%Infile.def"
call :remove
  
:: module Outfile
set rmFile="%srcpath%Outfile.def"
call :remove
  
:: module Proc
set rmFile="%srcpath%Proc.def"
call :remove
  
:: module Size
set rmFile="%srcpath%Size.def"
call :remove
  
:: module String
set rmFile="%srcpath%String.def"
call :remove
set rmFile="%srcpath%imp/String.mod"
call :remove
  
:: module Terminal
set rmFile="%srcpath%Terminal.def"
call :remove
set rmFile="%srcpath%imp/Terminal.mod"
call :remove
  
:: module BasicFileIO
set rmFile="%srcpath%imp\BasicFileIO.mod"
call :remove
  
:: module BasicFileSys
set rmFile="%srcpath%imp\BasicFileSys.mod"
call :remove
  
:: posix interfaces and shim libraries
set rmFile="%srcpath%stdio.def"
call :remove
set rmFile="%srcpath%stdio0.def"
call :remove
set rmFile="%srcpath%unistd.def"
call :remove
set rmFile="%srcpath%unistd0.def"
call :remove
set rmFile="%srcpath%imp\stdio.mod"
call :remove
set rmFile="%srcpath%imp\unistd.mod"
call :remove
  
set rmFile="%srcpath%BuildInfo.def"
call :remove

set rmFile=

echo Clean configuration completed.
EXIT /B 0

:: ---------------------------------------------------------------------------
:: remove file
:: ---------------------------------------------------------------------------
:: removes file at path $1, prints info
:: ---------------------------------------------------------------------------
:remove
if EXIST %rmFile% (
    echo "removing %rmFile"
	if NOT "%test%" == "true" (
		del %rmFile%
	)
    echo ""
)
EXIT /B 0

:: ---------------------------------------------------------------------------
:: generate build info file
:: ---------------------------------------------------------------------------
:: expands template BuildInfo.gen.def with build configuration parameters
:: ---------------------------------------------------------------------------
:genBuildInfo
:: TODO Convert to DOS format.  Lack of sed on DOS is a point of special concern
::local osname="$(uname -rs)"
::  local hardware="$(uname -m)"
::  local platform="${osname} (${hardware})"
::  local sub1="s|##platform##|\"${platform}\"|;"
::  local sub2="s|##dialect##|\"${dialect}\"|;"
::  local sub3="s|##compiler##|\"${compiler}\"|;"
::  local sub4="s|##iolib##|\"${iolib}\"|;"
::  local sub5="s|##mm##|\"${mm}\"|;"
::  sed -e "${sub1}${sub2}${sub3}${sub4}${sub5}" "${srcpath}templates/BuildInfo.gen.def" > "${srcpath}BuildInfo.def"
EXIT /B 0

:: ---------------------------------------------------------------------------
:: run main script
:: ---------------------------------------------------------------------------
CALL :main %*

pause