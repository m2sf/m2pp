(*!m2iso*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE FileSystemAdapter; (* ISO version *)

(* Clean file system interface to the junk that comes with ISO *)

IMPORT ChanConsts, SeqFile; (* ISO's junk libraries *)


CONST
  FileOpened = ChanConsts.opened;
  FileAlreadyExists = ChanConsts.fileExists;
  FileAlreadyOpen = ChanConsts.alreadyOpen;


PROCEDURE fileExists ( path : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if the file at the given path exists, else FALSE. *)

VAR
  found : BOOLEAN;
  f : SeqFile.ChanId;
  res : SeqFile.OpenResults;

  (* The ISO library doesn't provide any file lookup function. So we have
     no choice but to open a file just to see if it exists, and if it does
     exist then we have to close it again. This is bad design. *)

BEGIN
  (* Why do we need to decide between sequential, stream and random access
     when all we want is check if a file exists? Incredibly bad design. *)
     
  SeqFile.OpenRead(f, path, SeqFile.read+SeqFile.old, res);
  
  (* There are plenty of failure result codes that do not actually tell us
     whether or not the file exists. We have no choice but to deem that it
     doesn't exist if any of these failure codes are reported back.
     The incompetence in the ISO I/O library design is staggering. *)
  found :=
    (res = FileOpened) OR
    (res = FileAlreadyExists) OR
    (res = FileAlreadyOpen);
    
  IF res = FileOpened THEN
    SeqFile.Close(f)
  END; (* IF *)
  
  RETURN found
END fileExists;


PROCEDURE CreateFile ( path : ARRAY OF CHAR; VAR status : Status );
(* Creates a new file with the given pathname and passes back status. *)

BEGIN
  (* TO DO *)
END CreateFile;


PROCEDURE RenameFile ( path, newPath : ARRAY OF CHAR; VAR status : Status );
(* Renames the file at path to newPath and passes back status. *)

BEGIN
  (* TO DO *)
END RenameFile;


PROCEDURE DeleteFile ( path : ARRAY OF CHAR; VAR status : Status );
(* Deletes the file at path and passes status in done. *)

BEGIN
  (* TO DO *)
END DeleteFile;


END FileSystemAdapter.