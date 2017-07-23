(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE BasicFileSys; (* Ulm version *)

(* Basic Filesystem interface for M2PP and M2BSK *)

IMPORT SysAccess, Files; (* Ulm specific libraries *)

FROM stdio IMPORT INT, rename, remove;
FROM unistd IMPORT FileOK, CreateOnly, access, unlink;


PROCEDURE fileExists ( path : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if the file at the given path exists, else FALSE. *)

BEGIN
  RETURN SysAccess.Access(path, 0)
END fileExists;


PROCEDURE GetFileSize
  ( path : ARRAY OF CHAR; VAR size : FileSize; VAR status : Status );
(* Obtains the size of the file at path. On success, the size is passed back
   in size and Success is passed back in status. On failure, size remains
   unmodified and the FileNotFound or Failure is passed back in status. *)

BEGIN
  (* TO DO *)
END GetFileSize;


PROCEDURE CreateFile ( path : ARRAY OF CHAR; VAR status : Status );
(* Creates a new file with the given pathname and passes back status. *)

VAR
  f : StdIO.File;

BEGIN
  IF fileExists(path) THEN
    status := FileAlreadyExists;
    RETURN
  END; (* IF *)
  
  done := StdIO.Fopen(f, path, StdIO.write, FALSE);
  
  IF done THEN
    done := StdIO.Fclose(f);
    
    IF done THEN
      status := Success
    ELSE
      status := Failure
    END (* IF *)
  ELSE
    status := Failure
  END (* IF *)
END CreateFile;


PROCEDURE RenameFile ( path, newPath : ARRAY OF CHAR; VAR status : Status );
(* Renames the file at path to newPath and passes back status. *)

VAR
  res : INT;
  
BEGIN
  IF NOT fileExists(path) THEN
    status := FileNotFound;
    RETURN
  END; (* IF *)
  
  IF fileExists(newPath) THEN
    status := FileAlreadyExists;
    RETURN
  END; (* IF *)
  
  Files.Remame(path, newPath);
  
  IF fileExists(newPath) AND NOT fileExists(path) THEN
    status := Success
  ELSE
    status := Failure
  END (* IF *)
END RenameFile;


PROCEDURE DeleteFile ( path : ARRAY OF CHAR; VAR status : Status );
(* Deletes the file at path and passes status in done. *)

VAR
  res : INT;

BEGIN
  IF NOT fileExists(path) THEN
    status := FileNotFound;
    RETURN
  END; (* IF *)
  
  Files.Delete(path);
  
  IF fileExists(path) THEN
    status := Failure
  ELSE
    status := Success
  END (* IF *)
END DeleteFile;


END BasicFileSys.