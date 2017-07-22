(*!m2pim+gpm*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE FileSystemAdapter; (* GPM version *)

IMPORT FLength, PathLookup, UxFiles; (* GPM specific libraries *)


PROCEDURE fileExists ( path : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if the file at the given path exists, else FALSE. *)

CONST
  NUL = CHR(0);
  
VAR
  found : BOOLEAN;
  dirpath  : ARRAY [0..175] OF CHAR;
  dummy,
  filename : ARRAY [0..79] OF CHAR;

BEGIN
  (* bail out if path is empty *)
  IF path[0] = NUL THEN
    RETURN FALSE
  END; (* IF *)
  
  (* search for NUL terminator from left to right *)
  index := 0;
  WHILE (index <= HIGH(path)) AND (path[index] # NUL) DO
    index := index + 1
  END; (* WHILE *)
  
  (* search for dir separator from right to left *)
  ch := path[index];
  WHILE (index > 0) AND (ch # '/') AND (ch # BACKSLASH) DO
    index := index - 1;
    ch := path[index]
  END; (* WHILE *)
  
  IF (ch = '/') OR (ch = BACKSLASH) THEN
  
    (* copy path[0..index] to dirpath *)
    
    (* copy path[index+1..len] to filename *)
    
    PathLookup.FindAbsName(dirpath, filename, dummy, found)
  ELSE (* no dir path *)
    PathLookup.FindAbsName("", path, dummy, found)
  END; (* IF *)
    
  RETURN found
END fileExists;


PROCEDURE CreateFile ( path : ARRAY OF CHAR; VAR status : Status );
(* Creates a new file with the given pathname and passes back status. *)

VAR
  done : BOOLEAN;
  f : UxFiles.File;

BEGIN
  IF fileExists(path) THEN
    status := FileAlreadyExists;
    RETURN
  END; (* IF *)

  UxFiles.Create(f, path, done);
  
  IF done THEN
    status := Success;
    UxFiles.Close(f, done)
  ELSE
    status := Failure
  END (* IF *)
END CreateFile;


PROCEDURE RenameFile ( path, newPath : ARRAY OF CHAR; VAR status : Status );
(* Renames the file at path to newPath and passes back status. *)

VAR
  done : BOOLEAN;
  
BEGIN
  IF NOT fileExists(path) THEN
    status := FileNotFound;
    RETURN
  END; (* IF *)
  
  IF fileExists(newPath) THEN
    status := FileAlreadyExists;
    RETURN
  END; (* IF *)
  
  Flength.RenameFile(path, newPath, done); (* GPM specific call *)
  
  IF done THEN
    status := Success
  ELSE
    status := Failure
  END (* IF *)
END RenameFile;


PROCEDURE DeleteFile ( path : ARRAY OF CHAR; VAR status : Status );
(* Deletes the file at path and passes status in done. *)

VAR
  done : BOOLEAN;
  
BEGIN
  IF NOT fileExists(path) THEN
    status := FileNotFound;
    RETURN
  END; (* IF *)
  
  UxFiles.DeleteFile(path, done); (* GPM specific call *)
  
  IF done THEN
    status := Success
  ELSE
    status := Failure
  END (* IF *)
END DeleteFile;


END FileSystemAdapter.