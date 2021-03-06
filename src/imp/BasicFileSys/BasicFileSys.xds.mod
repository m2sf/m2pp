(*!m2iso*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE BasicFileSys; (* XDS version *)

(* Clean file system interface to the junk that comes with ISO *)

IMPORT ChanConsts, RndFile; (* ISO libraries *)

IMPORT FileSys; (* XDS specific library *)

IMPORT Size;


CONST
  Opened = ChanConsts.opened;
  NotFound = ChanConsts.noSuchFile;
  ExistsAlready = ChanConsts.fileExists;
  OpenAlready = ChanConsts.alreadyOpen;


PROCEDURE fileExists ( path : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if the file at the given path exists, else FALSE. *)

BEGIN
  RETURN FileSys.Exists(path)
END fileExists;


PROCEDURE GetFileSize
  ( path : ARRAY OF CHAR; VAR size : FileSize; VAR status : Status );
(* Obtains the size of the file at path. On success, the size is passed back
   in size and Success is passed back in status. On failure, size remains
   unmodified, FileNotFound, SizeOverflow or Failure is passed in status. *)

(* This procedure requires FilePos arithmetic and conversion which is not
   supported by all ISO Modula-2 compilers. For a truly portable but very
   inefficient implementation of GetFileSize, see BasicFileSys.p1.mod. *)

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
  
  fileSize := RndFile.EndPos(f);
  RndFile.Close(f);
  
  IF wouldOverflowFileSize(fileSize) THEN
    status := SizeOverflow;
    RETURN
  END; (* IF *)
  
  size := VAL(FileSize, fileSize);
  status := Success
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
  
  FileSys.Rename(path, newPath, done); (* XDS specific call *)
  
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
  
  FileSys.Remove(path, done); (* XDS specific call *)
  
  IF done THEN
    status := Success
  ELSE
    status := Failure
  END (* IF *)
END DeleteFile;


(* ************************************************************************ *
 * Private Operations                                                       *
 * ************************************************************************ *)

(* --------------------------------------------------------------------------
 * function wouldOverflowFileSize(size)
 * --------------------------------------------------------------------------
 * Returns TRUE if size > MAX(FileSize), else FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE wouldOverflowFileSize ( size : RndFile.FilePos ) : BOOLEAN;

VAR
  bits : CARDINAL;
  weight, maxWeight : RndFile.FilePos;

BEGIN
  bits := 0;
  weight := 1;
  maxWeight := size DIV 2 + 1;
  
  (* calculate required bits *)
  WHILE weight < maxWeight DO
    bits := bits + 1;
    weight := weight * 2
  END; (* WHILE *)
  
  RETURN ((bits + 1) > Size.BitsInUse)
END wouldOverflowFileSize;


END BasicFileSys.