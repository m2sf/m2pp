(*!m2iso*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE FNStr;

(* Filename string operations *)

IMPORT CharArray, FileSystemAdapter;

FROM ISO646 IMPORT NUL, BACKSLASH;
FROM CardMath IMPORT pow10, log10;
FROM String IMPORT StringT; (* alias for String.String *)


CONST
  outExt = ".out";
  bakExt = ".BAK";


VAR
  verLimit : BackupVersionRange;


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
  found, genFound, extFound : BOOLEAN;
  fnPos, genPos, extPos, srcIndex, tgtIndex, len, count : CARDINAL;
  target : ARRAY [0..MaxPathLen] OF CHAR;

BEGIN
  (* bail out if source is NIL *)
  IF (sourceName = String.Nil) THEN
    RETURN String.Nil
  END; (* IF *)
  
  (* bail out if source is empty *)
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
  
  FindExtension(target, genFound, genPos, extFound, extPos);
  
  IF extFound THEN
    IF genFound THEN
      (* remove '.gen' from target *)
      CharArray.RemoveSlice(target, genPos, genPos+3)
    ELSE (* no '.gen' *)
      (* insert '.out' before extension *)
      CharArray.InsertCharsAtIndex(target, outExt, extPos)
    END (* IF *)
    
  ELSE (* no extension *)
    IF genFound THEN
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

VAR
  len, index : CARDINAL;
  target : ARRAY [0..MaxPathLen] OF CHAR;
  
BEGIN
  (* bail out if original is NIL *)
  IF (origName = String.Nil) THEN
    RETURN String.Nil
  END; (* IF *)
  
  (* bail out if original is empty *)
  len := String.length(origName);
  IF (len = 0) THEN
    RETURN String.Nil
  END; (* IF *)
  
  (* target := original *)
  String.CopyToArray(origName, target, charsCopied);
  IF charsCopied = 0 THEN
    RETURN String.Nil
  END; (* IF *)
  
  RemoveTrailingPeriods(target, len);
  
  (* bail out if resulting name is empty *)
  IF len = 0 THEN
    RETURN String.Nil
  END; (* IF *)
  
  CharArray.AppendArray(target, bakExt);
  
  IF FileSystemAdapter.fileExists(target) THEN
    version := 1;
    WHILE version < verLimit DO
      AppendVersionSuffix(target, version, done);
      
      (* bail out if capacity is insufficient *)
      IF NOT done THEN
        (* path too long *)
        RETURN String.Nil
      END; (* IF *)
      
      (* return backup name if no such file exists *)
      IF NOT FileSystemAdapter.fileExist(target) THEN
        RETURN String.forArray(target)
      END; (* IF *)
      
      (* else remove suffix and increment version *)
      RemoveVersionSuffix(target);
      version := version + 1
    END (* WHILE *)
  END (* IF *)
END backupName;


(* ---------------------------------------------------------------------------
 * procedure FNStr.SetBackupVersionLimit(value)
 * ---------------------------------------------------------------------------
 * Sets the version limit for version suffixing by function backupName().
 * ------------------------------------------------------------------------ *)

PROCEDURE SetBackupVersionLimit ( value : BackupVersionRange );

BEGIN
  verLimit := value
END SetBackupVersionLimit;


(* ---------------------------------------------------------------------------
 * function FNStr.backupVersionLimit()
 * ---------------------------------------------------------------------------
 * Returns the version limit for version suffixing by function backupName().
 * ------------------------------------------------------------------------ *)

PROCEDURE backupVersionLimit () : CARDINAL;

BEGIN
  RETURN verLimit
END backupVersionLimit;


(* ************************************************************************ *
 * Private Operations                                                       *
 * ************************************************************************ *)

(* ---------------------------------------------------------------------------
 * procedure FindExtension(target, genFound, genPos, extFound, extPos)
 * ---------------------------------------------------------------------------
 * Searches from right to left for an extension in array before any directory
 * delimiter ('/', '\', ':' or ']') is reached. If no extension is found,
 * FALSE is passed back in both genFound and extFound and genPos and extPos
 * remain unmodified. If an extension is found and it is '.gen', TRUE is
 * passed in genFound and FALSE is passed in extFound. The index of the
 * period is passed in genPos and extPos remains unmodified. If any other
 * extension is found, TRUE is passed in extFound and the index of the
 * period is passed in extPos. If the extension is preceded by '.gen',
 * TRUE is also passed in genPos and the index of the the start of the
 * character sequence '.gen' is passed in genPos.
 * ------------------------------------------------------------------------ *)

PROCEDURE FindExtension
  ( VAR (* CONST *) target : ARRAY OF CHAR; 
    VAR genFound : BOOLEAN; VAR genPos : CARDINAL;
    VAR extFound : BOOLEAN; VAR extPos : CARDINAL );

VAR
  len, index : CARDINAL;
  
BEGIN
  genFound := FALSE;
  extFound := FALSE;
  len := CharArray.length(target);
  
  (* bail out if array is empty *)
  IF len = 0 THEN
    RETURN
  END; (* IF *)
  
  (* look for rightmost period *)
  FindPeriodR2L(array, found, index);
  
  IF (NOT found) OR (index + 1 >= len) THEN
    RETURN
  END; (* IF *)
  
  IF (index + 4 = len) AND matchesGenAtIndex(array, index) THEN
    genFound := TRUE; genPos := index;
    extFound := FALSE;
    RETURN
  END; (* IF *)
  
  extFound := TRUE; extPos := index;
  
  IF (index > 4) AND matchesGenAtIndex(array, index-4) THEN
    genFound := TRUE; genPos := index - 4
  END (* IF *)
END FindExtension;


(* ---------------------------------------------------------------------------
 * procedure RemoveTrailingPeriods(array, len)
 * ---------------------------------------------------------------------------
 * Removes any trailing '.' in array and passes the new length back in len.
 * ------------------------------------------------------------------------ *)

PROCEDURE RemoveTrailingPeriods
  ( VAR array : ARRAY OF CHAR; VAR len : CARDINAL );

BEGIN
  len := CharArray.length(array);
  
  IF len = 0 THEN
    RETURN
  END; (* IF *)
  
  WHILE len > 0 DO
    IF array[len-1] = '.' THEN
      array[len-1] := NUL;
      len := len - 1
    ELSE
      RETURN
    END (* IF *)
  END (* WHILE *)
END RemoveTrailingPeriods;


(* ---------------------------------------------------------------------------
 * procedure FindPeriodR2L(array, found, pos)
 * ---------------------------------------------------------------------------
 * Searches from right to left for the rightmost period in array before any
 * directory delimiter ('/', '\', ':' or ']') is reached. If a period is
 * found, TRUE is passed back in found and the index in pos. Otherwise,
 * FALSE is passed back in found and pos remains unmodified.
 * ------------------------------------------------------------------------ *)

PROCEDURE FindPeriodR2L
  ( VAR (* CONST *) array : ARRAY OF CHAR;
    VAR found : BOOLEAN; VAR pos : CARDINAL );

VAR
  ch : CHAR;
  len, index : CARDINAL;
  
BEGIN
  len := CharArray.length(array);
  
  (* bail out if array is empty *)
  IF len := 0 THEN
    found := FALSE;
    RETURN
  END; (* IF *)
  
  FOR index := len-1 TO 0 BY -1 DO
    ch = array[index];
    
    (* dirpath delimiter reached *)
    IF (ch = '/') OR (ch = BACKSLASH) OR (ch = ':') OR (ch = ']') THEN
      found := FALSE;
      RETURN
    
    (* period found *)
    ELSIF ch = '.' THEN
      found := TRUE;
      pos := index;
      RETURN
    END (* IF *)
  END; (* FOR *)
  
  found := FALSE
END FindPeriodR2L;


(* ---------------------------------------------------------------------------
 * function matchesGenAtIndex(array, index)
 * ---------------------------------------------------------------------------
 * Returns TRUE if slice array[index..index+4] matches the character sequence
 * '.gen.' or '.gen' followed by ASCII NUL. Returns FALSE otherwise.
 * ------------------------------------------------------------------------ *)

PROCEDURE matchesGenAtIndex
  ( VAR array : ARRAY OF CHAR; index : CARDINAL ) : BOOLEAN;

BEGIN
  RETURN
    (target + 4 <= HIGH(array)) AND
    (target[index] = '.') AND (target[index+1] = 'g') AND
    (target[index+2] = 'e') AND(target[index+3] = 'n') AND
    ((target[index+4] = '.') OR (target[index+4] = NUL))
END matchesGenAtIndex;


(* ---------------------------------------------------------------------------
 * procedure AppendVersionSuffix(path, version, done)
 * ---------------------------------------------------------------------------
 * Appends a version suffix to path. The version suffix is comprised of ';'
 * and the digits of the given version. The array passed in for path must have
 * sufficient capacity to append the suffix. If there is sufficient capacity,
 * the suffix is appended to path and TRUE is passed in done. Otherwise, path
 * remains unmodified and FALSE is passed in done.
 * ------------------------------------------------------------------------ *)

PROCEDURE AppendVersionSuffix
  ( VAR path : ARRAY OF CHAR;
    version  : BackupVersionRange;
    VAR done : BOOLEAN );

BEGIN
  capacity := HIGH(path);
  IF capacity = 0 THEN
    done := FALSE;
    RETURN
  END; (* IF *)
  
  (* adjust for NUL terminator *)
  capacity := capacity - 1;
  
  (* get current length *)
  len := CharArray.length(path);
  
  (* highest decimal exponent of version *)
  verLog10 := log10(version);
  
  (* calculate length of version suffix including semicolon *)
  suffixLen := (* digits *) verLog10 + 1 (* + semicolon *) + 1;
  
  (* check if array has capacity for version suffix *)
  IF len + suffixLen > capacity THEN
    done := FALSE;
    RETURN
  END; (* IF *)
  
  (* append semicolon *)
  AppendChar(path, ';');
  
  (* append version digits *)
  weight := pow10(verLog10);
  WHILE weight > 0 DO
    digit := version DIV weight;
    AppendChar(path, CHR(digit + 48));
    version := version MOD weight;
    weight := weight DIV 10
  END; (* WHILE *)
  
  done := TRUE
END AppendVersionSuffix;


(* ---------------------------------------------------------------------------
 * procedure RemoveVersionSuffix(path)
 * ---------------------------------------------------------------------------
 * Removes a version suffix from path.
 * ------------------------------------------------------------------------ *)

PROCEDURE RemoveVersionSuffix ( VAR path : ARRAY OF CHAR );

VAR
  ch : CHAR;
  len, index : CARDINAL;
  
BEGIN
  len := CharArray.length(array);
  
  (* bail out if array is empty *)
  IF len := 0 THEN
    RETURN
  END; (* IF *)
  
  FOR index := len - 1 TO 0 BY -1 DO
    ch := path[index];
    IF ch = ';' THEN
      path[index] := NUL
      RETURN
    ELSIF (ch = '/') OR (ch = BACKSLASH) OR (ch = ':') OR (ch = ']') THEN
      RETURN     
    END (* IF *)
  END (* FOR *)
END RemoveVersionSuffix;


(* ---------------------------------------------------------------------------
 * procedure AppendChar(array, ch)
 * ---------------------------------------------------------------------------
 * Appends ch to array if array has sufficient capacity.
 * ------------------------------------------------------------------------ *)

PROCEDURE AppendChar ( VAR array : ARRAY OF CHAR; ch : CHAR );

BEGIN
  len := CharArray.length(array);
  IF len < HIGH(array) THEN
    array[len] := ch;
    array[len+1] := NUL
  END (* IF *)
END AppendChar;


BEGIN (* FNStr *)
  verLimit := DefaultBackupVersionLimit
END FNStr.