@echo off

::!/bin/bash
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
if %1 == "clean" (
	set clean=true
	
	if %2 == -t set or_2 = T
	if %2 == --test set or_2 = T
	
	if "%or_2%" == T (
		set test=true
	) else (
		set test=false
) else (	
	if %1 == -t set or_1 = T
	if %1 == --test set or_1 = T
	
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
set /p dialect=1) ISO Modula-2	 2) PIM Modula-2	3) Quit Modula-2 dialect:  

if %dialect% == 1 (
	set dialectID=iso
) else (

	if %dialect% == 2 (
		set dialectID=pim
	) else (
	
		if %dialect% == 3 (
			EXIT 0
		) else (
		
			echo Invalid input.
			call :dialectMenu
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
	
		echo.
		echo internal error: invalid dialectID
		EXIT 1
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
set iso[1]=gm2
set iso[2]=gpm
set iso[3]=p1
set iso[4]=xds

echo 1) GNU Modula-2
echo 2) GPM Modula-2
echo 3) p1 Modula-2
echo 4) XDS Modula-2
echo 5) Quit

set /p compiler=Select Compiler: 

if "%compiler%"=="" (
	echo Invalid Input.
	call :isoCompilerMenu
)

if %compiler% LEQ 4  (
call set compilerID=%%iso[%compiler%]%%
) else (

	if %compiler% == 5 (
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
set pim[1]=ack
set pim[2]=gm2
set pim[3]=mocka
set pim[4]=ulm
set pim[5]=pim

echo 1) ACK Modula-2
echo 2) GNU Modula-2
echo 3) MOCKA Modula-2
echo 4) Ulm's Modula-2
echo 5) Generic Pim Compiler
echo 6) Quit

set /p compiler=Select Compiler:

if "%compiler%"=="" (
	echo Invalid Input.
	call :pimCompilerMenu
)

if %compiler% LEQ 5  (
call set compilerID=%%pim[%compiler%]%%
) else (

	if %compiler% == 6 (
		EXIT 0
		) else (
		
			echo Invalid input.
			call :pimCompilerMenu
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
if !compilerID! == gpm (
	set iolib=vendor library
	set iolibID=gpm
	echo $iolib
	goto :end
) 

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
if "!compilerID!" == "ack" ( set isPosix=true )
if "!compilerID!" == "mocka" ( set isPosix=true )

if defined isPosix (
	set iolib=POSIX I/O library
	set iolibID=posix
	echo $iolib
	goto :end
) 

if !compilerID! == ulm (
	set iolib=vendor library
	set iolibID=ulm
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
:: TODO confirm intended meaning?

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
EXIT /B 0

:: ---------------------------------------------------------------------------
:: copy file
:: ---------------------------------------------------------------------------
:: copies first argument to second argument, prints info
:: ---------------------------------------------------------------------------
:copyFile
::TODO implement variables into echoes
echo copying %1
echo      to %2

if NOT %test% == true (
	
)
EXIT /B 0

:: ---------------------------------------------------------------------------
:: clean files
:: ---------------------------------------------------------------------------
:cleanFiles
echo.

echo Clean configuration completed.
EXIT /B 0

:: ---------------------------------------------------------------------------
:: remove file
:: ---------------------------------------------------------------------------
:: removes file at path $1, prints info
:: ---------------------------------------------------------------------------
:remove
EXIT /B 0

:: ---------------------------------------------------------------------------
:: generate build info file
:: ---------------------------------------------------------------------------
:: expands template BuildInfo.gen.def with build configuration parameters
:: ---------------------------------------------------------------------------
:genBuildInfo
EXIT /B 0

:: ---------------------------------------------------------------------------
:: run main script
:: ---------------------------------------------------------------------------
CALL :main %*

pause