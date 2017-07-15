(*!m2iso*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

DEFINITION MODULE FNStr;

(* Filename string operations *)

IMPORT CharArray;

FROM String IMPORT StringT; (* alias for String.String *)


CONST
  outExt = ".out";
  bakExt = ".BAK";


VAR
  bvl : BackupVersionRange;


(* ---------------------------------------------------------------------------
 * function FNStr.targetName(source)
 * ---------------------------------------------------------------------------
 * Returns a target pathname for a given source pathname. The target path is
 * derived from the source path as follows. (1) If the source path does not
 * contain any extension, '.out' is appended to it. Otherwise, (2a) if its
 * extension is '.gen', the extension is replaced with '.out'; or (2b) if
 * its extension is preceded by '.gen', then the '.gen' part is removed.
 * (3) In any other case '.out' is inserted before the extension.
 *
 * Examples:
 *
 * case | source string     | returned string
 * -----+-------------------+------------------
 * (1)  | FooBarBaz         | FooBarBaz.out
 * (2a) | FooBarBaz.gen     | FooBarBaz.out
 * (2b) | FooBarBaz.gen.def | FooBarBaz.def
 * (3)  | FooBarBaz.def     | FooBarBaz.out.def
 * ------------------------------------------------------------------------ *)

PROCEDURE targetName ( sourceName : StringT ) : StringT;

VAR
  found, hasGen, hasExt : BOOLEAN;
  fnPos, genPos, extPos, srcIndex, tgtIndex, len, count : CARDINAL;
  target : ARRAY [0..MaxPathLen] OF CHAR;

BEGIN
  (* bail out of source is *)
  IF (sourceName = String.Nil) THEN
    RETURN String.Nil
  END; (* IF *)
  
  len := String.length(sourceName);
  IF (len = 0) THEN
    RETURN String.Nil
  END; (* IF *)
  
  (* target := source *)
  String.CopyToArray(sourceName, target, charsCopied);
  IF charsCopied = 0 THEN
    RETURN String.Nil
  END; (* IF *)
  
  FindFilename(target, found, fnPos);
  IF NOT found THEN
    RETURN String.Nil
  END; (* IF *)
  
  FindExtension(target, hasGen, genPos, hasExt, extPos);
  
  IF hasExt THEN
    IF hasGen THEN
      (* remove '.gen' from target *)
      CharArray.RemoveSlice(target, genPos, genPos+3)
    ELSE (* no '.gen' *)
      (* insert '.out' before extension *)
      CharArray.InsertCharsAtIndex(target, outExt, extPos)
    END (* IF *)
    
  ELSE (* no extension *)
    IF hasGen THEN
      CharArray.RemoveSlice(target, genPos, genPos+3)
    END; (* IF *)
    CharArray.AppendArray(target, outExt)
  END; (* IF *)
  
  RETURN String.forArray(target)
END targetName;


(* ---------------------------------------------------------------------------
 * function FNStr.backupName(source)
 * ---------------------------------------------------------------------------
 * Returns a backup pathname for a given original pathname. The backup path is
 * derived from the original path by appending extension '.BAK'. If a backup
 * file with the same name already exists, then a version suffix is appended.
 * A version suffix consists of ';' followed by a non-negative integer number
 * starting at 1. For each new version suffixed name, the version number is
 * increased by 1. A Nil string is returned if the version limit is reached.
 *
 * Examples:
 *
 * original string     | returned backup string
 * --------------------+-----------------------
 * FooBarBaz.def       | FooBarBaz.def.BAK
 * FooBarBaz.def.BAK   | FooBarBaz.def.BAK;1
 * FooBarBaz.def.BAK;1 | FooBarBaz.def.BAK;2
 * FooBarBaz.def.BAK;2 | FooBarBaz.def.BAK;3
 * ------------------------------------------------------------------------ *)

PROCEDURE backupName ( origName : StringT ) : StringT;

BEGIN
  (* TO DO *)
END backupName;


(* ---------------------------------------------------------------------------
 * procedure FNStr.SetBackupVersionLimit(value)
 * ---------------------------------------------------------------------------
 * Sets the version limit for version suffixing by function backupName().
 * ------------------------------------------------------------------------ *)

PROCEDURE SetBackupVersionLimit ( value : BackupVersionRange );

BEGIN
  bvl := value
END SetBackupVersionLimit;


(* ---------------------------------------------------------------------------
 * function FNStr.backupVersionLimit()
 * ---------------------------------------------------------------------------
 * Returns the version limit for version suffixing by function backupName().
 * ------------------------------------------------------------------------ *)

PROCEDURE backupVersionLimit () : CARDINAL;

BEGIN
  RETURN bvl
END backupVersionLimit;


BEGIN
  bvl := DefaultBackupVersionLimit
END FNStr.