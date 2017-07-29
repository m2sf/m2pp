(*!m2iso+gpm*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE BasicFileSys; (* GPM version *)

IMPORT FLength, UxFiles; (* GPM specific libraries *)


PROCEDURE fileExists ( path : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if the file at the given path exists, else FALSE. *)

VAR
  done : BOOLEAN;
  mode : UxFiles.FileMode;
  
BEGIN
  mode := { UxFiles.isreg };
  UxFiles.GetMode(path, mode, done);
  
  IF NOT done THEN
    RETURN FALSE
  END; (* IF *)
  
  RETURN (UxFiles.isreg IN mode)
END fileExists;


PROCEDURE GetFileSize
  ( path : ARRAY OF CHAR; VAR size : FileSize; VAR status : Status );
(* Obtains the size of the file at path. On success, the size is passed back
   in size and Success is passed back in status. On failure, size remains
   unmodified and FileNotFound or Failure is passed back in status. *)

VAR
  done : BOOLEAN;
  fileSize : CARDINAL;
  
BEGIN
  IF NOT fileExists(path) THEN
    status := FileNotFound;
    RETURN
  END; (* IF *)
  
  UxFiles.FileSize(path, fileSize, done);
  
  IF done THEN
    size := fileSize;
    status := Success
  ELSE
    status := Failure
  END (* IF *)
END GetFileSize;


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

  UxFiles.Create(f, path, done); (* GPM specific call *)
  
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


END BasicFileSys.