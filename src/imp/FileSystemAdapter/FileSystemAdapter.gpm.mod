(*!m2pim+gpm*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE FileSystemAdapter; (* GPM version *)

IMPORT UxFiles, FLength; (* GPM specific libraries *)


PROCEDURE fileExists ( path : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if the file at the given path exists, else FALSE. *)

VAR
  found : BOOLEAN;

BEGIN
  (* TO DO *)
  
  (* use FindAbsName in module pathlookup *)
  
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