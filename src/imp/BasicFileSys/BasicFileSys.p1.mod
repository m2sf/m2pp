(*!m2iso+p1*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE BasicFileSys; (* p1 version *)

(* Clean file system interface to the junk that comes with ISO *)

IMPORT ChanConsts, StreamFile; (* ISO libraries *)

FROM SYSTEM IMPORT INT32;
FROM stdio IMPORT rename, remove;


CONST
  Opened = ChanConsts.opened;
  NotFound = ChanConsts.noSuchFile;
  ExistsAlready = ChanConsts.fileExists;
  OpenAlready = ChanConsts.alreadyOpen;


PROCEDURE fileExists ( path : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if the file at the given path exists, else FALSE. *)

VAR
  found : BOOLEAN;
  f : StreamFile.ChanId;
  res : StreamFile.OpenResults;

  (* The ISO library doesn't provide any file lookup function. So we have
     no choice but to open a file just to see if it exists, and if it does
     exist then we have to close it again. This is bad design. *)

BEGIN
  (* Why do we need to decide between sequential, stream and random access
     when all we want is check if a file exists? Incredibly bad design. *)
     
  StreamFile.OpenRead(f, path, StreamFile.read+StreamFile.old, res);
  
  (* There are plenty of failure result codes that do not actually tell us
     whether or not the file exists. We have no choice but to deem that it
     doesn't exist if any of these failure codes are reported back.
     The incompetence in the ISO I/O library design is staggering. *)
  found :=
    (res = Opened) OR
    (res = ExistsAlready) OR
    (res = OpenAlready);
    
  IF res = Opened THEN
    StreamFile.Close(f)
  END; (* IF *)
  
  RETURN found
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
  f : StreamFile.ChanId;
  res : StreamFile.OpenResults;

BEGIN
  StreamFile.Open(f, path, write, res);
  
  IF res = Opened THEN
    status := Success;
    StreamFile.Close(f)
    
  ELSIF (res = ExistsAlready) OR (res = OpenAlready) THEN
    status := FileAlreadyExists
  ELSE
    status := Failure
  END (* IF *)
END CreateFile;


PROCEDURE RenameFile ( path, newPath : ARRAY OF CHAR; VAR status : Status );
(* Renames the file at path to newPath and passes back status. *)

VAR
  res : INT32;
  
BEGIN
  IF NOT fileExists(path) THEN
    status := FileNotFound;
    RETURN
  END; (* IF *)
  
  IF fileExists(newPath) THEN
    status := FileAlreadyExists;
    RETURN
  END; (* IF *)
  
  res := rename(path, newPath); (* foreign call *)
  
  IF res = 0 THEN
    status := Success
  ELSE
    status := Failure
  END (* IF *)
END RenameFile;


PROCEDURE DeleteFile ( path : ARRAY OF CHAR; VAR status : Status );
(* Deletes the file at path and passes status in done. *)

VAR
  res : INT32;
  
BEGIN
  IF NOT fileExists(path) THEN
    status := FileNotFound;
    RETURN
  END; (* IF *)
  
  res := remove(path); (* foreign call *)
  
  IF res = 0 THEN
    status := Success
  ELSE
    status := Failure
  END (* IF *)
END DeleteFile;


END BasicFileSys.