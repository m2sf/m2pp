(*!m2iso+p1*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE BasicFileSys; (* p1 version *)

(* Clean file system interface to the junk that comes with ISO *)

IMPORT ChanConsts, IOResult, RawIO, RndFile; (* ISO libraries *)

FROM stdio IMPORT INT, rename, remove;


CONST
  Opened = ChanConsts.opened;
  NotFound = ChanConsts.noSuchFile;
  ExistsAlready = ChanConsts.fileExists;
  OpenAlready = ChanConsts.alreadyOpen;


PROCEDURE fileExists ( path : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if the file at the given path exists, else FALSE. *)

VAR
  found : BOOLEAN;
  f : RndFile.ChanId;
  res : RndFile.OpenResults;

  (* The ISO library doesn't provide any file lookup function. So we have
     no choice but to open a file just to see if it exists, and if it does
     exist then we have to close it again. This is bad design. *)

BEGIN
  (* Why do we need to decide between sequential, stream and random access
     when all we want is check if a file exists? Incredibly bad design. *)
     
  RndFile.OpenOld(f, path, RndFile.read+RndFile.old, res);
  
  (* There are plenty of failure result codes that do not actually tell us
     whether or not the file exists. We have no choice but to deem that it
     doesn't exist if any of these failure codes are reported back.
     The incompetence in the ISO I/O library design is staggering. *)
  found :=
    (res = Opened) OR
    (res = ExistsAlready) OR
    (res = OpenAlready);
    
  IF res = Opened THEN
    RndFile.Close(f)
  END; (* IF *)
    
  RETURN found
END fileExists;


PROCEDURE GetFileSize
  ( path : ARRAY OF CHAR; VAR size : FileSize; VAR status : Status );
(* Obtains the size of the file at path. On success, the size is passed back
   in size and Success is passed back in status. On failure, size remains
   unmodified and FileNotFound or Failure is passed back in status. *)

VAR
  ch : CHAR;
  found : BOOLEAN;
  f : RndFile.ChanId;
  counter : FileSize;
  res : RndFile.OpenResults;

  (* The p1 compiler does not permit any arithmetic on values of type FilePos
     nor does it permit conversion to another type. As ridiculous as this may
     seem, it does not violate the ISO standard which defines type FilePos as
     an array and does not require it to support arithmetic nor conversion.
     We therefore have no choice but to open the file, read it byte by byte
     to the end while incrementing a counter to obtain the filesize as a
     value of a useful type. This is terribly inefficiant, especially on
     larger files. The penalty for using such a badly designed standard. *)

BEGIN
  RndFile.OpenOld(f, path, RndFile.read+RndFile.old, res);
  
  found :=
    (res = Opened) OR
    (res = ExistsAlready) OR
    (res = OpenAlready);
  
  IF NOT found THEN
    status := FileNotFound;
    RETURN
  END; (* IF *)
      
  IF res # Opened THEN
    status := Failure;
    RETURN
  END; (* IF *)
  
  counter := 0;
  WHILE IOResult.ReadResult(f) # IOResult.endOfInput DO
    RawIO.Read(f, ch);
    
    IF counter = MAX(FileSize) THEN
      status := SizeOverflow;
      RndFile.Close(f);
      RETURN
    END; (* IF *)
    
    counter := counter + 1      
  END; (* WHILE *)
  
  RndFile.Close(f);
  status := Success;
  size := counter
END GetFileSize;


PROCEDURE CreateFile ( path : ARRAY OF CHAR; VAR status : Status );
(* Creates a new file with the given pathname and passes back status. *)

VAR
  f : RndFile.ChanId;
  res : RndFile.OpenResults;

BEGIN
  RndFile.OpenClean(f, path, RndFile.write, res);
  
  IF res = Opened THEN
    status := Success;
    RndFile.Close(f)
    
  ELSIF (res = ExistsAlready) OR (res = OpenAlready) THEN
    status := FileAlreadyExists
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
  res : INT;
  
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