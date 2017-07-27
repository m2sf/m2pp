(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE Settings;

(* Program wide settings management *)

IMPORT String, Newline, Tabulator;

FROM String IMPORT StringT; (* alias for String.String *)


TYPE Settings = SET OF Setting;


CONST
  InfileDefault = String.Nil;
  OutfileDefault = String.Nil;
  TabWidthDefault = Tabulator.Default;
  NewlineModeDefault = Newline.Default;
  VerboseDefault = FALSE;
  ShowSettingsDefault = FALSE;


VAR
  infileStr,
  outfileStr : StringT;
  verboseFlag,
  showSettingsFlag : BOOLEAN;
  modifiedSettings : Settings;
  

PROCEDURE Reset ( setting : Setting );
(* Resets setting to its default. *)

BEGIN
  CASE setting OF
    Infile :
      infileStr := InfileDefault
  | Outfile :
      outfileStr := OutfileDefault
  | TabWidth :
      Tabulator.SetTabWidth(TabWidthDefault)
  | NewlineMode :
      Newline.SetMode(NewlineModeDefault)
  | Verbose :
      verboseFlag := VerboseDefault
  | ShowSettings :
      showSettingsFlag := ShowSettingsDefault
  END; (* CASE *)
  
  EXCL(modifiedSettings, setting)
END Reset;


PROCEDURE alreadySet ( setting : Setting ) : BOOLEAN;
(* Returns TRUE if setting has been modified since last reset, else FALSE. *)

BEGIN
  RETURN setting IN modifiedSettings
END alreadySet;


PROCEDURE SetInfile ( path : StringT );
(* Sets the infile setting to path. *)

BEGIN
  infileStr := path;
  INCL(modifiedSettings, Infile)
END SetInfile;


PROCEDURE infile () : StringT;
(* Returns the infile setting. *)

BEGIN
  RETURN infileStr
END infile;


PROCEDURE SetOutfile ( path : StringT );
(* Sets the outfile setting to path. *)

BEGIN
  outfileStr := path;
  EXCL(modifiedSettings, Outfile)
END SetOutfile;


PROCEDURE outfile () : StringT;
(* Returns the outfile setting. *)

BEGIN
  RETURN outfileStr
END outfile;


PROCEDURE SetTabWidth ( value : Tabulator.TabWidth );
(* Sets the tabwidth setting to value. *)

BEGIN
  Tabulator.SetTabWidth(value);
  INCL(modifiedSettings, TabWidth)
END SetTabWidth;


PROCEDURE tabWidth () : Tabulator.TabWidth;
(* Returns the tabwidth setting. *)

BEGIN
  RETURN Tabulator.tabWidth()
END tabWidth;


PROCEDURE SetNewlineMode ( mode : Newline.Mode );
(* Sets the newline mode setting to mode. *)

BEGIN
  Newline.SetMode(mode);
  INCL(modifiedSettings, NewlineMode)
END SetNewlineMode;


PROCEDURE newlineMode () : Newline.Mode;
(* Returns the newline mode setting. *)

BEGIN
  RETURN Newline.mode()
END newlineMode;


PROCEDURE SetVerbose ( value : BOOLEAN );
(* Sets the verbose setting. *)

BEGIN
  verboseFlag := value;
  INCL(modifiedSettings, Verbose)
END SetVerbose;


PROCEDURE verbose () : BOOLEAN;
(* Returns the verbose setting. *)

BEGIN
  RETURN verboseFlag
END verbose;


PROCEDURE SetShowSettings ( value : BOOLEAN );
(* Sets the show-settings setting. *)

BEGIN
  showSettingsFlag := value;
  INCL(modifiedSettings, ShowSettings)
END SetShowSettings;


PROCEDURE showSettings () : BOOLEAN;
(* Returns the show-settings setting. *)

BEGIN
  RETURN showSettingsFlag
END showSettings;


PROCEDURE ResetAll;
(* Resets all settings to their defaults. *)

VAR
  setting : Setting;
  
BEGIN
  FOR setting := MIN(Setting) TO MAX(Setting) DO
    Reset(setting)
  END (* FOR *)
END ResetAll;


BEGIN (* Settings *)
  modifiedSettings := Settings {};
  infileStr := InfileDefault;
  outfileStr := OutfileDefault;
  verboseFlag := VerboseDefault;
  showSettingsFlag := ShowSettingsDefault
END Settings.