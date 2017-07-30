(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE BasicFileSys; (* Ulm version *)

(* Basic Filesystem interface for M2PP and M2BSK *)

IMPORT SystemTypes, SysAccess, SysStat, Files; (* Ulm specific libraries *)

IMPORT Size;

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
   unmodified, FileNotFound, SizeOverflow or Failure is passed in status. *)

VAR
  done : BOOLEAN;
  stat : SysStat.StatBuf;
  
BEGIN
  IF NOT fileExists(path) THEN
    status := FileNotFound;
    RETURN
  END; (* IF *)
  
  done := SysStat.Stat(path, stat);
  
  IF NOT done THEN
    status := Failure;
    RETURN
  END; (* IF *)
  
  IF wouldOverflowFileSize(stat.size) THEN
    status := SizeOverflow;
    RETURN
  END; (* IF *)
  
  size := VAL(FileSize, stat.size);
  status := Success
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


(* ************************************************************************ *
 * Private Operations                                                       *
 * ************************************************************************ *)

(* --------------------------------------------------------------------------
 * function wouldOverflowFileSize(size)
 * --------------------------------------------------------------------------
 * Returns TRUE if size > MAX(FileSize), else FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE wouldOverflowFileSize ( size : SystemTypes.OFF ) : BOOLEAN;

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