(*!m2iso*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE Tabulator;

(* Tabulator management *)

VAR defaultTabWidth : TabWidth;


PROCEDURE SetTabWidth ( value : TabWidth );
(* Sets the default tab width. Zero leaves tabs in place. *)

BEGIN
  defaultTabWidth := value
END SetTabWidth;


PROCEDURE tabWidth ( ) : TabWidth;
(* Returns the default tab width. *)

BEGIN
  RETURN defaultTabWidth;
END tabWidth;


BEGIN
  defaultTabWidth := 0
END Tabulator.