(*!m2iso+sbu*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE FileSystemAdapter; (* ADW version *)

(* Clean file system interface to the junk that comes with ISO *)

IMPORT ChanConsts, StreamFile; (* ISO's junk libraries *)

IMPORT RTL; (* ADW specific library *)


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
  
  done := RTL.RenameFile(path, newPath); (* ADW specific call *)
  
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
  
  done := RTL.DeleteFile(path); (* ADW specific call *)
  
  IF done THEN
    status := Success
  ELSE
    status := Failure
  END (* IF *)
END DeleteFile;


END FileSystemAdapter.
