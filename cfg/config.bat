@echo off

:: config.bat * Copyright (c) 2017 Modula-2 Software Foundation
:: usage:
:: config [clean] [--test | -t]

:: ---------------------------------------------------------------------------
:: main script
:: ---------------------------------------------------------------------------

:main
echo *** M2PP build configuration script for DOS/Windows ***

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
echo Dialect Selection
echo 1) ISO Modula-2
echo 2) PIM Modula-2
echo 3) GPM Modula-2
echo 4) Quit Modula-2 dialect:  
set /p dialect="Modula-2 dialect: "

if %dialect% == 1 (
	set dialectID=iso
	set dialect=ISO Modula-2
) else (

	if %dialect% == 2 (
		set dialectID=pim
		set dialect=PIM Modula-2
	) else (

		if %dialect% == 3 (
			set dialectID=gpm
			set dialect=GPM Modula-2
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
:: sets global variables compiler and compilerID
:: ---------------------------------------------------------------------------

:compilerMenu

if %dialectID% == iso (
	echo.
	echo Compiler Selection
	call :isoCompilerMenu
) else (
	if %dialectID% == pim (
		set compilerID=pim
		set compiler=Generic PIM Compiler
	) else (

		if %dialectID% == gpm (
			set compilerID=gpm
			set compiler=GPM
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
:: sets global variables compiler and compilerID
:: ---------------------------------------------------------------------------

:isoCompilerMenu
set iso[1]=adw
set iso[2]=xds
set iso[3]=clarion
set isod[1]=ADW Modula-2
set isod[2]=XDS Modula-2
set isod[3]=Clarion Modula-2

echo 1) %isod[1]%
echo 2) %isod[2]%
::echo 3) %isod[3]%
echo 3) Quit

set /p compilerinput="Modula-2 compiler: "

if "%compilerinput%"=="" (
	echo Invalid Input.
	call :isoCompilerMenu
)

if %compilerinput% LEQ 2  (
	call set compilerID=%%iso[%compilerinput%]%%
	call set compiler=%%isod[%compilerinput%]%%
) else (
	if %compilerinput% == 3 (
		EXIT 0
		) else (
		
			echo Invalid input.
			call :isoCompilerMenu
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
if %dialectID%==iso ( 
	echo.
	echo I/O Library Selection
	call :isoIolibMenu 
) else (
	if %dialectID%==pim ( 
		set iolibID=pim
		set iolib=PIM
	) else (

		if %dialectID%==gpm ( 
			set iolib=Vendor I/O library
			set iolibID=gpm
		) else (
	
		echo.
		echo internal error: invalid dialectID
		)
	)
)
EXIT /B 0

:: ---------------------------------------------------------------------------
:: ISO compiler I/O library selection
:: ---------------------------------------------------------------------------
:: sets global variables iolib and iolibID
:: ---------------------------------------------------------------------------
:isoIolibMenu

echo 1) ISO I/O library
echo 2) Windows I/O library
echo 3) Quit
set /p iolibinput="I/O library: "

if "%iolibinput%" == "1" (
	set iolibID=iso
	set iolib=ISO I/O library
)
 
if "%iolibinput%" == "2" (
	set iolibID=windows
	set iolib=Windows I/O library
) 
	
if "%iolibinput%" == "3" (
	exit
) 
	
if NOT "%iolibinput%" LEQ "3" (
	echo Invalid Input.
	call :isoIolibMenu
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

set /p mminput="Memory Model: "

if "%mminput%"=="" (
	echo Invalid Input.
	call :memModelMenu
)

if %mminput% LEQ 5  (

	if %mminput%==2 (
		set mmID=longint
	) else (
	
		set mmID=cardinal
	)
) else (

	if %mminput% == 6 (
		EXIT 0
		) else (
		
			echo Invalid input.
			call :memModelMenu
		)
	)
)
if %mminput% == 1 set mm="16/16 bits"
if %mminput% == 2 set mm="16/32 bits"
if %mminput% == 3 set mm="32/32 bits"
if %mminput% == 4 set mm="32/64 bits"
if %mminput% == 5 set mm="64/64 bits"
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
set char2=%srcpath:~1,1%

set fullpath=false
:: First character \ is current disk absolute path
if "%char1%" == "\" (
	set fullpath=true
)
:: Second character : is specified disk absolute path
if "%char2%" == ":" (
	set fullpath=true
)

if NOT "%fullpath%" == "true" (
	call set srcpath=%systemdrive%%homepath%\%srcpath%
)
 
::changed / to \ because windows uses \ in directories
set lastchar=%srcpath:~-1%
if NOT "%lastchar%" == "\" ( 	
	set "srcpath=%srcpath%\"
)

if NOT EXIST %srcpath% (
	echo directory %srcpath% does not exist
	pause
	exit
)
 
EXIT /B 0

:: ---------------------------------------------------------------------------
:: print summary and get user confirmation
:: ---------------------------------------------------------------------------
:: exits unless user confirmation is obtained
:: ---------------------------------------------------------------------------
:getConfirmation
echo.
echo Selected build configuration
echo Dialect       : %dialect% (%dialectID%)
echo Compiler      : %compiler% (%compilerID%)
echo I/O library   : %iolib% (%iolibID%)
echo Memory model  : %mm%(%mmID%)
echo M2PP src path : %srcpath%
echo.

set /p confirm="Are these details correct? (y/n) : "

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
if "%iolibID"=="iso" (
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
if "%iolibID"=="pim" (
	set sourceFile="%srcpath%imp\BasicFileSys\BasicFileSys.%iolibID%.mod"
	set destinationFile="%srcpath%imp\BasicFileSys.mod"
	call :copyFile
) else (
	set sourceFile="%srcpath%imp\BasicFileSys\BasicFileSys.%compilerID%.mod"
	set destinationFile="%srcpath%imp\BasicFileSys.mod"
	call :copyFile
)
  
:: foreign interface modules stdio and unistd
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
echo.
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
set rmFile="%srcpath%imp\String.mod"
call :remove
  
:: module Terminal
set rmFile="%srcpath%Terminal.def"
call :remove
set rmFile="%srcpath%imp\Terminal.mod"
call :remove
  
:: module BasicFileIO
set rmFile="%srcpath%imp\BasicFileIO.mod"
call :remove
  
:: module BasicFileSys
set rmFile="%srcpath%imp\BasicFileSys.mod"
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
    echo removing %rmFile%
	if NOT "%test%" == "true" (
		del %rmFile%
	)
    echo.
)
EXIT /B 0

:: ---------------------------------------------------------------------------
:: generate build info file
:: ---------------------------------------------------------------------------
:: expands template BuildInfo.gen.def with build configuration parameters
:: ---------------------------------------------------------------------------
:genBuildInfo
copy "%srcpath%templates\BuildInfo.gen.def" "%srcpath%BuildInfo.def" > nul

set osname=%OS%
set hardware=%Processor_Architecture%
set platform="%osname% (%hardware%)"

set textfile="%srcpath%BuildInfo.def"

set search="##platform##"
set replace=%platform%
call :sed
set search="##dialect##"
set replace=%dialect%
call :sed
set search="##compiler##"
set replace=%compiler%
call :sed
set search="##iolib##"
set replace=%iolib%
call :sed
set search="##mm##"
set replace=%mm%
call :sed

EXIT /B 0

:: ---------------------------------------------------------------------------
:: do simple text replacements
:: ---------------------------------------------------------------------------
:: fill out BuildInfo template with build configuration parameters
:: ---------------------------------------------------------------------------
:sed
:: TODO replace %search% with %replace% in %textfile%
echo %search% - %replace% in %textfile%

EXIT /B 0

:: ---------------------------------------------------------------------------
:: run main script
:: ---------------------------------------------------------------------------
CALL :main %*