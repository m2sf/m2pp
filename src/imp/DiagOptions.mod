(*!m2iso*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE DiagOptions;

(* Diagnostic Option Settings *)

IMPORT String, Console;

FROM String IMPORT StringT; (* alias for String.String *)


TYPE Option =
  ( Verbose,         (* --verbose *)
    ShowSettings );  (* --show-settings *)


(* Properties *)

VAR
  options : SET OF Option;
  optionStr : ARRAY Option OF StringT;


(* Operations *)

(* ---------------------------------------------------------------------------
 * procedure SetOption(option, value)
 * ---------------------------------------------------------------------------
 * Sets the given option to the given boolean FALSE.
 * ------------------------------------------------------------------------ *)

PROCEDURE SetOption ( option : Option; value : BOOLEAN );

BEGIN
  IF value = TRUE THEN
    INCL(options, value)
  ELSE (* value = FALSE *)
    EXCL(options, value)
  END
END SetOption;


(* ---------------------------------------------------------------------------
 * function verbose()
 * ---------------------------------------------------------------------------
 * Returns TRUE if option --verbose is turned on, else FALSE.
 * ------------------------------------------------------------------------ *)

PROCEDURE verbose () : BOOLEAN;

BEGIN
  RETURN (Verbose IN options)
END verbose;


(* ---------------------------------------------------------------------------
 * function showSettings()
 * ---------------------------------------------------------------------------
 * Returns TRUE if option --show-settings is turned on, else FALSE.
 * ------------------------------------------------------------------------ *)

PROCEDURE showSettings () : BOOLEAN;

BEGIN
  RETURN (ShowSettings IN options)
END showSettings;


BEGIN (* DiagOptions *)
  (* init option set *)
  option := { };
  
  (* init option name strings *)
  optionStr[Verbose] := String.forArray("Verbose");
  optionStr[ShowSettings] := String.forArray("ShowSettings");
END DiagOptions.