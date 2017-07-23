(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE FileSystemAdapter; (* POSIX version *)

(* Clean file system interface based on POSIX,
   not using any of the junk that comes with PIM and ISO *)

FROM stdio IMPORT INT, rename, remove;
FROM unistd IMPORT FileOK, CreateOnly, access, unlink;


PROCEDURE fileExists ( path : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if the file at the given path exists, else FALSE. *)

BEGIN
  RETURN (access(path, FileOK) = 0)
END fileExists;


PROCEDURE CreateFile ( path : ARRAY OF CHAR; VAR status : Status );
(* Creates a new file with the given pathname and passes back status. *)

VAR
  res : INT;

BEGIN
  IF access(path) # 0 THEN
    status := FileNotFound;
    RETURN
  END; (* IF *)
  
  res := open(path, CreateOnly);
    
  IF res # -1 THEN
    status := Success;
  ELSE
    status := Failure
  END (* IF *)
END CreateFile;


PROCEDURE RenameFile ( path, newPath : ARRAY OF CHAR; VAR status : Status );
(* Renames the file at path to newPath and passes back status. *)

VAR
  res : INT;
  
BEGIN
  IF access(path) # 0 THEN
    status := FileNotFound;
    RETURN
  END; (* IF *)
  
  res := rename(path, newPath);
  
  IF res = 0 THEN
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
  IF access(path) # 0 THEN
    status := FileNotFound;
    RETURN
  END; (* IF *)
  
  res := unlink(path);
  
  IF res = 0 THEN
    status := Success
  ELSE
    status := Failure
  END (* IF *)
END DeleteFile;


END FileSystemAdapter.
