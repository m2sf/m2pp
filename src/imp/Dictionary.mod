(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation. *)

IMPLEMENTATION MODULE Dictionary;

(* Key/Value Dictionary *)

IMPORT String;

FROM String IMPORT StringT; (* alias for String.String *)


(* Introspection *)

PROCEDURE count ( ) : CARDINAL;
(* Returns the number of items in the global dictionary. *)

BEGIN
  (* TO DO *)
END count;


(* Lookup Operations *)

PROCEDURE isPresent ( VAR (* CONST *) key : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if a value is stored for key in the global dictionary. *)

BEGIN
  (* TO DO *)
END isPresent;


PROCEDURE stringForKey ( VAR (* CONST *) key : ARRAY OF CHAR ) : StringT;
(* Returns the string value stored for key, if key is present in the global
   dictionary. Returns NIL if key is not present in the global dictionary. *)

BEGIN
  (* TO DO *)
END stringForKey;


(* Insert Operations *)

PROCEDURE StoreArrayForKey
  ( VAR (* CONST *) key; VAR array : ARRAY OF CHAR );
(* Obtains an interned string for array,
   then stores the string for key in the global dictionary. *)

BEGIN
  (* TO DO *)
END StoreArrayForKey;


PROCEDURE StoreStringForKey
  ( VAR (* CONST *) key : ARRAY OF CHAR; string : StringT );
(* Stores string for key in the global dictionary. *)

BEGIN
  (* TO DO *)
END StoreStringForKey;


(* Removal Operations *)

PROCEDURE RemoveKey ( VAR (* CONST *) key );
(* Removes key and its value in the global dictionary. *)

BEGIN
  (* TO DO *)
END RemoveKey;


(* Iteration *)

PROCEDURE WithKeyValuePairsDo ( p : IterBodyProc );

BEGIN
  (* TO DO *)
END WithKeyValuePairsDo;


END Dictionary.