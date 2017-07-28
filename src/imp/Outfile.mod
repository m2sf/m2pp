(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE Outfile;

(* I/O library for writing text files with tab expansion *)

IMPORT BasicFileIO, String, Tabulator, Newline;

FROM SYSTEM IMPORT TSIZE;
FROM Storage IMPORT ALLOCATE, DEALLOCATE;
FROM ISO646 IMPORT NUL, TAB, LF, CR, SPACE, DEL;
FROM String IMPORT StringT; (* alias for String.String *)


(* ---------------------------------------------------------------------------
 * File type for reading
 * ------------------------------------------------------------------------ *)

TYPE Outfile = POINTER TO OutfileDescriptor;

TYPE OutfileDescriptor = RECORD
  file : BasicFileIO.File;
  line,
  column : CARDINAL;
  tabwidth : TabWidth;
  newlineMode : Newline.Mode
END; (* OutfileDescriptor *)


(* ---------------------------------------------------------------------------
 * procedure Open(outfile, path, status )
 * ---------------------------------------------------------------------------
 * Opens the file at path and passes a newly allocated and initialised outfile
 * object back in out-parameter outfile. Passes NilOutfile on failure.
 * ------------------------------------------------------------------------ *)

PROCEDURE Open
 ( VAR (* NEW *) outfile : Outfile;
   VAR (* CONST *) path  : ARRAY OF CHAR;
   VAR            status : BasicFileIO.Status );

VAR
  file : BasicFileIO.File;
  s : BasicFileIO.Status;
  
BEGIN
  BasicFileIO.Open(file, path, BasicFileIO.Write, s);
  
  IF s # BasicFileIO.Success THEN
    status := s;
    RETURN
  END; (* IF *)
  
  ALLOCATE(outfile, TSIZE(OutfileDescriptor));
  
  outfile^.file := file;
  outfile^.line := 1;
  outfile^.column := 1;
  outfile^.tabwidth := Tabulator.tabWidth();
  outfile^.newlineMode := Newline.mode()
END Open;


(* ---------------------------------------------------------------------------
 * procedure Close(outfile)
 * ---------------------------------------------------------------------------
 * Closes the file associated with outfile and passes NilOutfile in outfile.
 * ------------------------------------------------------------------------ *)

PROCEDURE Close ( VAR outfile : Outfile );

VAR
  s : BasicFileIO.Status;
  
BEGIN
  IF outfile = NIL THEN
    RETURN
  END; (* IF *)
  
  BasicFileIO.Close(outfile^.file, s);
  
  IF s = BasicFileIO.Success THEN
    outfile := NIL
  END (* IF *)
END Close;


(* ---------------------------------------------------------------------------
 * procedure SetTabWidth(outfile, value)
 * ---------------------------------------------------------------------------
 * Sets the tab width for outfile. The default value is two.
 * Operation only permitted prior to first write operation to outfile.
 * ------------------------------------------------------------------------ *)

PROCEDURE SetTabWidth ( outfile : Outfile; value : TabWidth );

BEGIN
  (* bail out if outfile has already been written to *)
  IF (outfile^.line > 1) OR (outfile^.column > 1) THEN
    RETURN
  END; (* IF *)
  
  outfile^.tabwidth := value
END SetTabWidth;


(* ---------------------------------------------------------------------------
 * procedure SetNewlineMode(outfile, mode)
 * ---------------------------------------------------------------------------
 * Sets the newline mode for outfile. The default is Newline.mode().
 * Operation only permitted prior to first write operation to outfile.
 * ------------------------------------------------------------------------ *)

PROCEDURE SetNewlineMode ( outfile : Outfile; mode : Newline.Mode );

BEGIN
  (* bail out if outfile has already been written to *)
  IF (outfile^.line > 1) OR (outfile^.column > 1) THEN
    RETURN
  END; (* IF *)
  
  (* set newline mode *)
  outfile^.newlineMode := mode
END SetNewlineMode;


(* ---------------------------------------------------------------------------
 * procedure WriteChar(outfile, ch)
 * ---------------------------------------------------------------------------
 * Writes character ch to outfile. Control characters are ignored.
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteChar ( outfile : Outfile; ch : CHAR );

BEGIN
  (* write ch to outfile if printable char *)
  IF (ch >= SPACE) AND (ch # DEL) THEN
    BasicFileIO.WriteChar(outfile^.file, ch);
    outfile^.column := outfile^.column + 1
  END (* IF *)
END WriteChar;


(* ---------------------------------------------------------------------------
 * procedure WriteChars(outfile, array)
 * ---------------------------------------------------------------------------
 * Writes characters in array to outfile.
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteChars
  ( outfile : Outfile; VAR (* CONST *) array : ARRAY OF CHAR );

VAR
  ch : CHAR;
  index : CARDINAL;
  
BEGIN
  FOR index := 0 TO HIGH(array) DO
    (* get next char *)
    ch := array[index];
    
    (* done when NUL *)
    IF ch = NUL THEN
      RETURN
    END; (* IF *)
    
    (* write ch to outfile if printable char *)
    IF (ch >= SPACE) AND (ch # DEL) THEN
      BasicFileIO.WriteChar(outfile^.file, ch);
      outfile^.column := outfile^.column + 1
    END (* IF *)
  END (* FOR *)
END WriteChars;


(* ---------------------------------------------------------------------------
 * procedure WriteString(outfile, string)
 * ---------------------------------------------------------------------------
 * Writes string to outfile.
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteString ( outfile : Outfile; string : StringT );

VAR
  ch : CHAR;
  index : CARDINAL;
  
BEGIN
  FOR index := 0 TO String.length(string) DO
    (* get next char *)
    ch := String.charAtIndex(string, index);
    
    (* write ch to outfile if printable char *)
    IF (ch >= SPACE) AND (ch # DEL) THEN
      BasicFileIO.WriteChar(outfile^.file, ch);
      outfile^.column := outfile^.column + 1
    END (* IF *)
  END (* FOR *)
END WriteString;


(* ---------------------------------------------------------------------------
 * procedure WriteTab(outfile)
 * ---------------------------------------------------------------------------
 * Writes tab to outfile. Expands tabs to spaces if tabwidth > 0.
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteTab ( outfile : Outfile );

VAR
  spaces, counter : CARDINAL;
  
BEGIN
  IF outfile^.tabwidth = 0 THEN
    BasicFileIO.WriteChar(outfile^.file, TAB);
    (* update column counter *)
    outfile^.column := outfile^.column + 1
    
  ELSE (* tabwidth > 0 -- expand to spaces *)
    spaces := outfile^.tabwidth - (outfile^.column - 1) MOD outfile^.tabwidth;
    FOR counter := 1 TO spaces DO
      BasicFileIO.WriteChar(outfile^.file, SPACE)
    END; (* FOR *)
    (* update column counter *)
    outfile^.column := outfile^.column + spaces
  END (* IF *)
END WriteTab;


(* ---------------------------------------------------------------------------
 * procedure WriteLn(outfile)
 * ---------------------------------------------------------------------------
 * Writes newline to outfile.
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteLn ( outfile : Outfile );

BEGIN
  (* write newline according to newline mode *)
  CASE outfile^.newlineMode OF
    Newline.LF :
      BasicFileIO.WriteChar(outfile^.file, LF)
  | Newline.CR :
      BasicFileIO.WriteChar(outfile^.file, CR)
  | Newline.CRLF :
      BasicFileIO.WriteChar(outfile^.file, CR);
      BasicFileIO.WriteChar(outfile^.file, LF)
  END; (* CASE *)
  
  (* update line and column counters *)
  outfile^.line := outfile^.line + 1;
  outfile^.column := 1
END WriteLn;


(* ---------------------------------------------------------------------------
 * function status(outfile)
 * ---------------------------------------------------------------------------
 * Returns status of last operation.
 * ------------------------------------------------------------------------ *)

PROCEDURE status ( outfile : Outfile ) : BasicFileIO.Status;

BEGIN
  RETURN BasicFileIO.status(outfile^.file)
END status;


(* ---------------------------------------------------------------------------
 * procedure line(outfile)
 * ---------------------------------------------------------------------------
 * Returns the line number of the current writing position of outfile.
 * ------------------------------------------------------------------------ *)

PROCEDURE line ( outfile : Outfile ) : CARDINAL;

BEGIN
  RETURN outfile^.line
END line;


(* ---------------------------------------------------------------------------
 * procedure column(outfile)
 * ---------------------------------------------------------------------------
 * Returns the column number of the current writing position of outfile.
 * ------------------------------------------------------------------------ *)

PROCEDURE column ( outfile : Outfile ) : CARDINAL;

BEGIN
  RETURN outfile^.column
END column;


END Outfile.