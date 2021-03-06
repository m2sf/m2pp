(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation. *)

IMPLEMENTATION MODULE BasicFileIO; (* Ulm version *)

(* Basic File IO library for M2PP and M2BSK *)

IMPORT StdIO; (* Ulm low-level I/O library *)
IMPORT BasicFileSys;

FROM SYSTEM IMPORT BYTE;
FROM ISO646 IMPORT NUL, EOT;
FROM Storage IMPORT ALLOCATE, DEALLOCATE;


CONST BufferedIO = TRUE;

TYPE File = POINTER TO FileDescriptor;

TYPE FileDescriptor = RECORD
  ulmf   : StdIO.File;
  mode   : Mode;
  queue  : InsertQueue;
  status : Status;
END; (* FileDescriptor *)


CONST InsertQueueSize = 8;

TYPE InsertQueue = RECORD
  count : CARDINAL [0..InsertQueueSize-1];
  char  : ARRAY [0..InsertQueueSize] OF CHAR
END; (* InsertBuffer *)


(* Operations *)

(* -----------------------------------------------------------------------
 * Support for an operation depends on the mode in which the file has
 * been opened. For details, see the table below.
 *
 * operation         | supported in file mode | sets
 *                   | Read    Write   Append | status
 * ------------------+------------------------+-------
 * Open              | yes     yes     yes    | yes
 * Close             | yes     yes     yes    | n/a
 * ------------------+------------------------+-------
 * GetMode           | yes     yes     yes    | no
 * status            | yes     yes     yes    | no
 * insertBufferFull  | yes     no*     no*    | no
 * eof               | yes     no*     no*    | no
 * ------------------+------------------------+-------
 * ReadChar          | yes     no      no     | yes
 * InsertChar        | yes     no      no     | yes
 * ReadChars         | yes     no      no     | yes
 * ReadOctet         | yes     no      no     | yes
 * InsertOctet       | yes     no      no     | yes
 * ReadOctets        | yes     no      no     | yes
 * ------------------+------------------------+-------
 * WriteChar         | no      yes     yes    | yes
 * WriteChars        | no      yes     yes    | yes
 * WriteOctet        | no      yes     yes    | yes
 * WriteOctets       | no      yes     yes    | yes
 * ------------------+------------------------+-------
 * key: trailing * = always returns FALSE, result is meaningless.
 * ----------------------------------------------------------------------- *)

(* Open and close *)

(* ---------------------------------------------------------------------------
 * procedure Open(file, path, mode, status)
 * ---------------------------------------------------------------------------
 * Opens the file at path in the given mode. Passes a new file object in file
 * and the status in status.  If the file does not exist, it will be created
 * when opened in write mode, otherwise FileNotFound is passed back in status.
 * When opening an already existing file in write mode, all of its current
 * contents will be overwritten.
 * ------------------------------------------------------------------------ *)

PROCEDURE Open
  ( VAR file : File; path : ARRAY OF CHAR; mode : Mode; VAR status : Status );

VAR
  ulmf : StdIO.File;
  done, found : BOOLEAN;
  fsStatus : BasicFileSys.Status;
  
BEGIN
  found := BasicFileSys.fileExists(path);
  
  IF NOT found AND ((mode = Read) OR (mode = Append)) THEN
    status := FileNotFound;
    RETURN
  END; (* IF *)
    
  CASE mode OF
    Read :
      done := StdIO.Open(ulmf, path, StdIO.read, BufferedIO)
      
  | Write :
      IF NOT Found THEN
        BasicFileSys.CreateFile(path, fsStatus);
        
        IF fsStatus # BasicFileSys.Success THEN
          status := Failure;
          RETURN
        END (* IF *)
      END; (* IF *)
      
      done := StdIO.Open(ulmf, path, StdIO.write, BufferedIO)
      
  | Append :
      done := StdIO.Open(ulmf, path, StdIO.append, BufferedIO)
  END; (* CASE *)
  
  IF NOT done THEN
    (* unable to open file *)
    status := Failure;
    RETURN
  END; (* IF *)
    
  ALLOCATE(file, TSIZE(FileDescriptor));
  
  IF file = NIL THEN
    status := AllocationFailed;
    done := StdIO.Close(ulmf);
    RETURN
  END; (* IF *)
  
  file^.ulmf := ulmf;
  file^.mode := mode;
  file^.queue.count := 0;
  file^.queue.char[0] := NUL;
  file^.status := Success;
  
  status := file^.status
END Open;


(* ---------------------------------------------------------------------------
 * procedure Close(file, status)
 * ---------------------------------------------------------------------------
 * Closes file. Passes status in status.
 * ------------------------------------------------------------------------ *)

PROCEDURE Close ( VAR file : File; VAR status : Status );

VAR
  done : BOOLEAN;
  
BEGIN
  IF file = NIL THEN
    status := InvalidFileRef;
    RETURN
  END; (* IF *)
  
  done := StdIO.Close(file^.uxf, done);
  
  IF done THEN
    DEALLOCATE(file, TSIZE(FileDescriptor));
    status := Success
  ELSE
    status := IOError
  END (* IF *)
END Close;


(* Introspection *)

(* ---------------------------------------------------------------------------
 * procedure GetMode(file, mode)
 * ---------------------------------------------------------------------------
 * Passes the mode of file in mode.
 * ------------------------------------------------------------------------ *)

PROCEDURE GetMode ( file : File; VAR mode : Mode );

BEGIN
  IF file = NIL THEN
    RETURN
  END; (* IF *)
  
  mode := file^.mode
END GetMode;


(* ---------------------------------------------------------------------------
 * function status(file)
 * ---------------------------------------------------------------------------
 * Returns the status of the last operation on file in status.
 * ------------------------------------------------------------------------ *)

PROCEDURE status ( file : File ) : Status;

BEGIN
  IF file = NIL THEN
    RETURN InvalidFileRef
  END; (* IF *)
  
  RETURN file^.status
END GetStatus;


(* ---------------------------------------------------------------------------
 * function insertBufferFull(file)
 * ---------------------------------------------------------------------------
 * Returns TRUE if the internal insert buffer of file is full, else FALSE.
 * ------------------------------------------------------------------------ *)

PROCEDURE insertBufferFull ( file : File ) : BOOLEAN;

BEGIN
  IF (file = NIL) OR (file^.mode # Read)THEN
    RETURN FALSE
  END; (* IF *)
  
  RETURN (file^.queue.count >= InsertQueueSize)
END insertBufferFull;


(* ---------------------------------------------------------------------------
 * function eof(file)
 * ---------------------------------------------------------------------------
 * Returns TRUE if the end of file has been reached, otherwise FALSE.
 * ------------------------------------------------------------------------ *)

PROCEDURE eof ( file : File ) : BOOLEAN;

BEGIN
  IF (file = NIL) OR (file^.mode # Read)THEN
    RETURN FALSE
  END; (* IF *)
  
  IF (* queue empty *) file^.queue.count = 0 THEN
    RETURN StdIO.Feof(file^.ulmf) 
  ELSE (* queue not empty *)
    RETURN FALSE
  END (* IF *)
END eof;


(* Read and unread operations *)

(* ---------------------------------------------------------------------------
 * procedure ReadChar(file, ch)
 * ---------------------------------------------------------------------------
 * If the internal insert buffer of file is not empty, removes the first
 * character from the buffer and returns it in out-parameter ch. Otherwise,
 * if the internal insert buffer of file is empty, reads one character at
 * the current reading position of file and passes it in ch, or ASCII EOT
 * if the end of file had already been reached upon entry into ReadChar.
 * ------------------------------------------------------------------------ *)

PROCEDURE ReadChar ( file : File; VAR ch : CHAR );

VAR
  done : BOOLEAN;

BEGIN
  IF file = NIL THEN
    RETURN
  ELSIF file^.mode # Read THEN
    file^.status := IllegalOperation
  END; (* IF *)
  
  IF (* queue empty *) file^.queue.count = 0 THEN
    done := StdIO.Fgetc(ch, file^.ulmf);
    IF done THEN
      file^.status := Success
    ELSIF StdIO.Feof(file^.ulmf) THEN
      file^.status := ReadBeyondEOF;
      ch := EOT
    ELSE
      file^.status := IOError
    END (* IF *)
  ELSE (* queue not empty *)
    RemoveChar(ch)
  END (* IF *)
END ReadChar;


(* ---------------------------------------------------------------------------
 * procedure InsertChar(file, ch)
 * ---------------------------------------------------------------------------
 * Inserts character ch into the internal insert buffer of file unless
 * the insert buffer is full. Sets file's status to InsertBufferFull if full.
 * ------------------------------------------------------------------------ *)

PROCEDURE InsertChar ( file : File; ch : CHAR ); (* Unread *)

BEGIN
  IF file = NIL  THEN
    RETURN
  ELSIF file^.mode # Read THEN
    file^.status := IllegalOperation
  END; (* IF *)
  
  IF (* queue not full *) file^.queue.count < InsertQueueSize THEN
    file^.queue.char[queue.count] := ch;
    file^.queue.count := file^.queue.count + 1
    
  ELSE (* queue full *)
    file^.status := InsertBufferFull
  END (* IF *)
END InsertChar;


(* ---------------------------------------------------------------------------
 * procedure ReadChars(file, buffer, charsRead)
 * ---------------------------------------------------------------------------
 * If the internal insert buffer of file is not empty, removes as many
 * characters from the insert buffer as will fit into out-parameter buffer
 * and copies them to out-parameter buffer.  If and once the internal insert
 * buffer is empty, reads contents starting at the current reading position
 * of file into out-parameter buffer until either the pen-ultimate index of
 * buffer is written or eof is reached. Out-parameter buffer is then termi-
 * nated with ASCII NUL. The number of chars copied is passed in charsRead.
 * ------------------------------------------------------------------------ *)

PROCEDURE ReadChars
  ( file : File; VAR buffer : ARRAY OF CHAR; VAR charsRead : CARDINAL );

VAR
  ch : CHAR;
  done : BOOLEAN;
  index : CARDINAL;
  
BEGIN
  IF file = NIL  THEN
    RETURN
  ELSIF file^.mode # Read THEN
    file^.status := IllegalOperation
  END; (* IF *)
  
  (* read chars from insert buffer *)
  index := 0;
  WHILE (index <= HIGH(buffer)) AND (file^.queue.count > 0) DO
    RemoveChar(ch);
    buffer[index] := ch;
    index := index + 1
  END; (* WHILE *)
  
  (* read chars from file *)
  WHILE done AND (index < HIGH(buffer))
    AND NOT StdIO.Feof(file^.umlf) DO
    
    done := StdIO.Fgetc(ch, file^.ulmf);
    IF done THEN
      buffer[index] := ch;
      index := index + 1
    END (* IF *)
  END; (* WHILE *)
  
  (* terminate buffer *)
  buffer[index] := NUL;
  
  IF NOT done THEN
    file^.status := Success
  ELSIF UxFiles.EndFile(file^.uxf) THEN
    file^.status := ReadBeyondEOF
  ELSE
    file^.status := IOError
  END; (* IF *)
  
  charsRead := index
END ReadChars;


(* ---------------------------------------------------------------------------
 * procedure ReadOctet(file, octet)
 * ---------------------------------------------------------------------------
 * If the internal insert buffer of file is not empty, removes the first
 * octet from the buffer and returns it in out-parameter octet. Otherwise,
 * if the internal insert buffer of file is empty, reads one octet at the
 * current reading position of file and passes it in octet unless the end
 * of file has been reached upon entry into ReadOctet.
 * ------------------------------------------------------------------------ *)

PROCEDURE ReadOctet ( file : File; VAR octet : Octet );

VAR
  ch : CHAR;
  done : BOOLEAN;

BEGIN
  IF file = NIL THEN
    RETURN
  ELSIF file^.mode # Read THEN
    file^.status := IllegalOperation
  END; (* IF *)
  
  IF (* queue empty *) file^.queue.count = 0 THEN
    done := StdIO.Fgetc(ch, file^.ulmf);
    IF done THEN
      file^.status := Success;
      octet := ORD(ch)
    ELSIF StdIO.Feof(file^.ulmf) THEN
      file^.status := ReadBeyondEOF
    ELSE
      file^.status := IOError
    END (* IF *)
  ELSE (* queue not empty *)
    RemoveChar(ch);
    octet := ORD(ch)
  END (* IF *)
END ReadOctet;


(* ---------------------------------------------------------------------------
 * procedure InsertOctet(file, octet)
 * ---------------------------------------------------------------------------
 * Inserts octet into the internal insert buffer of file unless
 * the insert buffer is full. Sets file's status to InsertBufferFull if full.
 * ------------------------------------------------------------------------ *)

PROCEDURE InsertOctet ( file : File; octet : Octet ); (* Unread *)

VAR
 ch : CHAR;
 
BEGIN
  IF file = NIL  THEN
    RETURN
  ELSIF file^.mode # Read THEN
    file^.status := IllegalOperation
  END; (* IF *)
  
  IF (* queue not full *) file^.queue.count < InsertQueueSize THEN
    file^.queue.char[queue.count] := CHR(octet);
    file^.queue.count := file^.queue.count + 1
    
  ELSE (* queue full *)
    file^.status := InsertBufferFull
  END (* IF *)
END InsertOctet;


(* ---------------------------------------------------------------------------
 * procedure ReadOctets(file, buffer, octetsRead)
 * ---------------------------------------------------------------------------
 * If the internal insert buffer of file is not empty, removes as many octets
 * from the insert buffer as will fit into out-parameter buffer and copies
 * them to out-parameter buffer.  If and once the internal insert buffer is
 * empty, reads contents starting at the current reading position of file into
 * out-parameter buffer until either the ultimate index of buffer is written
 * or eof is reached. The number of octets copied is passed in octetsRead.
 * ------------------------------------------------------------------------ *)

PROCEDURE ReadOctets
  ( file : File; VAR buffer : ARRAY OF Octet; VAR octetsRead : CARDINAL );

VAR
  ch : CHAR;
  done : BOOLEAN;
  index : CARDINAL;
  
BEGIN
  IF file = NIL  THEN
    RETURN
  ELSIF file^.mode # Read THEN
    file^.status := IllegalOperation
  END; (* IF *)
  
  (* read chars from insert buffer *)
  index := 0;
  WHILE (index <= HIGH(buffer)) AND (file^.queue.count > 0) DO
    RemoveChar(ch);
    buffer[index] := ORD(ch);
    index := index + 1
  END; (* WHILE *)
  
  (* read chars from file *)
  WHILE done AND (index < HIGH(buffer))
    AND NOT StdIO.Feof(file^.umlf) DO
    
    done := StdIO.Fgetc(ch, file^.ulmf);
    IF done THEN
      buffer[index] := ORD(ch);
      index := index + 1
    END (* IF *)
  END; (* WHILE *)
  
  IF NOT done THEN
    file^.status := Success
  ELSIF UxFiles.EndFile(file^.uxf) THEN
    file^.status := ReadBeyondEOF
  ELSE
    file^.status := IOError
  END; (* IF *)
    
  octetsRead := index
END ReadOctets;


(* Write operations *)

(* ---------------------------------------------------------------------------
 * procedure WriteChar(file, ch)
 * ---------------------------------------------------------------------------
 * Writes character ch to file at the current writing position.
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteChar ( file : File; ch : CHAR );

VAR
  done : BOOLEAN;
  
BEGIN
  IF file = NIL  THEN
    RETURN
  ELSIF file^.mode = Read THEN
    file^.status := IllegalOperation;
    RETURN
  END; (* IF *)
  
  (* write ch to file *)
  done := StdIO.Fputc(ch, file^.ulmf);
  
  IF done THEN
    file^.status := Success
  ELSE
    file^.status := IOError
  END (* IF *)
END WriteChar;


(* ---------------------------------------------------------------------------
 * procedure WriteChars(file, buffer, charsWritten)
 * ---------------------------------------------------------------------------
 * Writes the contents of buffer up to and excluding the first ASCII NUL
 * character code to file at the current writing position. The number of
 * characters actually written is passed in charsWritten.
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteChars
  ( file : File; buffer : ARRAY OF CHAR; VAR charsWritten : CARDINAL );

VAR
  done : BOOLEAN;
  index : CARDINAL;
  
BEGIN
  IF file = NIL  THEN
    RETURN
  ELSIF file^.mode = Read THEN
    file^.status := IllegalOperation
  END; (* IF *)
  
  index := 0;
  done := TRUE;
  WHILE done AND (index <= HIGH(buffer)) AND (buffer[index] # NUL) DO
    done := StdIO.Fputc(buffer[index], file^.ulmf);
    index := index + 1
  END; (* WHILE *)
  
  IF done THEN
    file^.status := Success
  ELSE
    file^.status := IOError
  END; (* IF *)
    
  charsWritten := index
END WriteChars;


(* ---------------------------------------------------------------------------
 * procedure WriteOctet(file, octet)
 * ---------------------------------------------------------------------------
 * Writes one octet to file at the current writing position.
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteOctet ( file : File; octet : Octet );

VAR
  done : BOOLEAN;
  
BEGIN
  IF file = NIL  THEN
    RETURN
  ELSIF file^.mode = Read THEN
    file^.status := IllegalOperation;
    RETURN
  END; (* IF *)
  
  (* write octet to file *)
  done := StdIO.Fputc(CHR(octet), file^.ulmf);
  
  IF done THEN
    file^.status := Success
  ELSE
    file^.status := IOError
  END (* IF *)
END WriteOctet;


(* ---------------------------------------------------------------------------
 * procedure WriteOctets(file, buffer, octetsWritten)
 * ---------------------------------------------------------------------------
 * Writes the contents of buffer to file at the current writing position. The
 * number of octets actually written is passed in octetsWritten.
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteOctets
  ( file : File; buffer : ARRAY OF Octet; VAR octetsWritten : CARDINAL );

VAR
  done : BOOLEAN;
  index : CARDINAL;
  
BEGIN
  IF file = NIL  THEN
    RETURN
  ELSIF file^.mode = Read THEN
    file^.status := IllegalOperation
  END; (* IF *)
  
  index := 0;
  done := TRUE;
  WHILE done AND (index <= HIGH(buffer)) DO
    done := StdIO.Fputc(CHR(buffer[index]), file^.ulmf);
    index := index + 1
  END; (* WHILE *)
  
  IF done THEN
    file^.status := Success
  ELSE
    file^.status := IOError
  END; (* IF *)
      
  octetsWritten := index
END WriteOctets;


(* ************************************************************************ *
 * Private Operations                                                       *
 * ************************************************************************ *)

(* ---------------------------------------------------------------------------
 * procedure Remove(ch)
 * ---------------------------------------------------------------------------
 * Removes the character at the head of f's insert queue unless it is empty.
 * Passes the removed character in ch, or NUL if the queue is empty.
 * ------------------------------------------------------------------------ *)

PROCEDURE RemoveChar ( file : File; VAR ch : CHAR );

VAR
  index : CARDINAL;
  
BEGIN
  IF (* empty *) file^.queue.count = 0 THEN
    ch := NUL
    
  ELSE (* not empty *)
    ch := file^.queue.char[0];
    index := 0;
    WHILE index < file^.queue.count DO
      file^.queue.char[index] := file^.queue.char[index + 1];
      index := index + 1
    END; (* WHILE *)
    
    file^.queue.char[index] := NUL;
    file^.queue.count := file^.queue.count - 1
  END (* IF *)
END RemoveChar;


END BasicFileIO.