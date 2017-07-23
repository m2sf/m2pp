(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE BasicFileSys; (* PIM version *)

(* Clean file system interface to the junk that came with PIM *)

IMPORT FileSystem; (* PIM's junk library *)


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


END BasicFileSys.