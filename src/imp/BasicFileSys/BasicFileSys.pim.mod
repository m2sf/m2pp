(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE BasicFileSys; (* PIM version *)

(* Clean file system interface to the junk that came with PIM *)

IMPORT FileSystem; (* PIM's junk library *)

IMPORT Size;


PROCEDURE fileExists ( path : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if the file at the given path exists, else FALSE. *)

VAR
  found : BOOLEAN;
  f : FileSystem.File;

  (* The PIM library doesn't actually have a file lookup function. It
     mislabels the open file function as lookup instead. So we have no
     choice but to open a file just to see if it exists, and if it does
     exist then we have to close it again. Bad design. *)

BEGIN
  FileSystem.Lookup(f, path, false);
  found := (f.res = FileSystem.done);
  
  IF FileSystem.opened IN f.flags THEN
    FileSystem.Close(f)
  END; (* IF *)
  
  RETURN found
END fileExists;


PROCEDURE GetFileSize
  ( path : ARRAY OF CHAR; VAR size : FileSize; VAR status : Status );
(* Obtains the size of the file at path. On success, the size is passed back
   in size and Success is passed back in status. On failure, size remains
   unmodified, FileNotFound, SizeOverflow or Failure is passed in status. *)

VAR
  found : BOOLEAN;
  f : FileSystem.File;
  high, low : CARDINAL;
  highFactor, highWeight : FileSize;

BEGIN
  FileSystem.Lookup(f, path, false);
  found := (f.res = FileSystem.done);
  
  IF NOT found THEN
    status := FileNotFound;
    RETURN
  END; (* IF *)
  
  IF FileSystem.opened IN f.flags THEN
    FileSystem.Length(f, high, low);
    FileSystem.Close(f)
  ELSE
    status := Failure;
    RETURN
  END (* IF *)
  
  IF high = 0 THEN
    IF wouldOverflowFileSize(low) THEN
      status := SizeOverflow;
      RETURN
    ELSE
      size := VAL(FileSize, low)
    END (* IF *)
    
  ELSE (* high > 0 *)
    IF MAX(FileSize) <= MAX(CARDINAL) THEN
      status := SizeOverflow;
      RETURN
    END; (* IF *)
    
    (* highFactor := 2^(bitwidth of CARDINAL) *)
    highFactor := VAL(FileSize, MAX(CARDINAL)) + 1;
    IF mulWouldOverflowFS(high, highFactor) THEN
      status := SizeOverflow;
      RETURN
    END; (* IF *)
    
    (* highWeight := high * 2^(bitwidth of CARDINAL)  *)
    highWeight := VAL(FileSize, high) * highFactor;
    IF addWouldOverflowFS(highWeight, low) THEN
      status := SizeOverflow;
      RETURN
    END; (* IF *)
    
    (* size := high * 2^(bitwidth of CARDINAL) + low *)
    size := highWeight + VAL(FileSize, low)
  END; (* IF *)
  
  status := Success
END GetFileSize;


PROCEDURE CreateFile ( path : ARRAY OF CHAR; VAR status : Status );
(* Creates a new file with the given pathname and passes back status. *)

VAR
  f : FileSystem.File;

BEGIN
  IF fileExists(path) THEN
    status := FileAlreadyExists;
    RETURN
  END; (* IF *)
  
  FileSystem.Create(f);
  IF f.res # FileSystem.done THEN
    status := Failure;
    RETURN
  END; (* IF *)
  
  FileSystem.Rename(f, path);
  IF f.res # FileSystem.done THEN
    status := Failure;
    RETURN
  END; (* IF *)
  
  (* see if the file has been opened and if so close it, just in case *)
  IF FileSystem.opened IN f.flags THEN
    FileSystem.Close(f)
  END (* IF *)
END CreateFile;


PROCEDURE RenameFile ( path, newPath : ARRAY OF CHAR; VAR status : Status );
(* Renames the file at path to newPath and passes back status. *)

VAR
  f : FileSystem.File;
  
BEGIN
  IF NOT fileExists(path) THEN
    status := FileNotFound;
    RETURN
  END; (* IF *)

  IF fileExists(newPath) THEN
    status := FileAlreadyExists;
    RETURN
  END; (* IF *)

  FileSystem.Lookup(f, path, false);
  FileSystem.Rename(f, path);
  
  IF f.res = FileSystem.done THEN
    status := Success
  ELSE
    status := Failure
  END; (* IF *)
  
  IF FileSystem.opened IN f.flags THEN
    FileSystem.Close(f)
  END (* IF *)
END RenameFile;


PROCEDURE DeleteFile ( path : ARRAY OF CHAR; VAR status : Status );
(* Deletes the file at path and passes status in done. *)

VAR
  f : FileSystem.File;
  
BEGIN
  IF NOT fileExists(path) THEN
    status := FileNotFound;
    RETURN
  END; (* IF *)
  
  FileSystem.Delete(path, f);
  
  IF f.res = FileSystem.done THEN
    status := Success
  ELSE
    status := Failure
  END (* IF *)
END DeleteFile;


(* ************************************************************************ *
 * Private Operations                                                       *
 * ************************************************************************ *)

PROCEDURE wouldOverflowFileSize ( n : CARDINAL ) : BOOLEAN;

BEGIN
  IF MAX(FileSize) > MAX(CARDINAL) THEN
    RETURN FALSE
  ELSE
    RETURN n > MAX(FileSize)
  END (* IF *)
END wouldOverflowFileSize;


PROCEDURE addWouldOverflowFS ( n, m : CARDINAL ) : BOOLEAN;

BEGIN
  IF valueWouldOverflowFS(n) THEN
    RETURN TRUE
  ELSIF valueWouldOverflowFS(m) THEN
    RETURN TRUE
  ELSE
    RETURN (MAX(FileSize) - m) < n
  END (* IF *)
END addWouldOverflowFS;


PROCEDURE mulWouldOverflowFS ( n, m : CARDINAL ) : BOOLEAN;

BEGIN
  IF m > 0 THEN
    RETURN ((MAX(FileSize) DIV m) < n)
  ELSE
    RETURN FALSE
  END (* IF *)
END mulWouldOverflowFS;


END BasicFileSys.