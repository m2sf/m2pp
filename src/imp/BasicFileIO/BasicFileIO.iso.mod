(*!m2iso*) (* Copyright (c) 2017 Modula-2 Software Foundation. *)

IMPLEMENTATION MODULE BasicFileIO; (* ISO version *)

(* Basic File IO library for M2PP and M2BSK *)

IMPORT SYSTEM, SeqFile, RawIO, IOResult;
IMPORT BasicFileSys;

FROM ISO646 IMPORT NUL, EOT;
FROM Storage IMPORT ALLOCATE, DEALLOCATE;
FROM IOChan IMPORT ChanId, InvalidChan;


TYPE File = POINTER TO FileDescriptor;

TYPE FileDescriptor = RECORD
  cid    : ChanId;
  mode   : Mode;
  queue  : InsertQueue;
  status : Status;
END; (* FileDescriptor *)


CONST InsertQueueSize = 8;

TYPE InsertQueue = RECORD
  count : CARDINAL [0..InsertQueueSize-1];
  char  : ARRAY [0..InsertQueueSize] OF CHAR
END; (* InsertBuffer *)


TYPE IOUnit = SYSTEM.LOC;


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
 * GetStatus         | yes     yes     yes    | no
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
  cid : ChanID;
  found : BOOLEAN;
  res : SeqFile.OpenResults;
  
BEGIN
  found := BasicFileSys.fileExists(path);
  
  IF NOT found AND ((mode = Read) OR (mode = Append)) THEN
    status := FileNotFound;
    RETURN
  END; (* IF *)
  
  CASE mode OF
    Read :
      SeqFile.OpenRead(cid, path, SeqFile.read, res)
      
  | Write :
      SeqFile.OpenWrite(cid, path, SeqFile.write+SeqFile.old, res)
      
  | Append :
      SeqFile.OpenAppend(cid, path, SeqFile.write+SeqFile.old, res)
  END; (* CASE *)
  
  IF res # SeqFile.opened THEN
    status := IOError; (* TO DO : refine *)
    RETURN
  END; (* IF *)
  
  ALLOCATE(file, TSIZE(FileDescriptor));
  
  IF file = NIL THEN
    status := AllocationFailed;
    SeqFile.Close(cid);
    RETURN
  END; (* IF *)
  
  file^.cid := cid;
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

BEGIN
  IF file = NIL THEN
    status := InvalidFileRef;
    RETURN
  END; (* IF *)
  
  SeqFile.Close(file^.cid);
  
  IF file^.cid = InvalidChan() THEN
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
 * procedure GetStatus(file, status)
 * ---------------------------------------------------------------------------
 * Passes the status of the last operation on file in status.
 * ------------------------------------------------------------------------ *)

PROCEDURE GetStatus ( file : File; VAR status : Status );

BEGIN
  IF file = NIL THEN
    status := InvalidFileRef;
    RETURN
  END; (* IF *)
  
  status := file^.status
END GetStatus;


(* ---------------------------------------------------------------------------
 * procedure insertBufferFull(file)
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
 * procedure eof(file)
 * ---------------------------------------------------------------------------
 * Returns TRUE if the end of file has been reached, otherwise FALSE.
 * ------------------------------------------------------------------------ *)

PROCEDURE eof ( file : File ) : BOOLEAN;

BEGIN
  IF (file = NIL) OR (file^.mode # Read)THEN
    RETURN FALSE
  END; (* IF *)
    
  IF (* queue empty *) file^.queue.count = 0 THEN
    RETURN (* How does one query EOF in ISO M2? *) 
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
  readCh : CHAR;
  res : IOResult.ReadResults;
  
BEGIN
  IF file = NIL THEN
    RETURN
  ELSIF file^.mode # Read THEN
    file^.status := IllegalOperation
  END; (* IF *)
  
  IF (* queue empty *) file^.queue.count = 0 THEN
    RawIO.Read(file^.cid, readCh);
    res := IOResult.ReadResult(file^.cid);
    IF res = IOResult.allRight THEN
      ch := readCh;
      file^.status := Success
    ELSIF res = IOResult.endOfInput THEN
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
  c : INT;
  ch : CHAR;
  index : CARDINAL;
  noError : BOOLEAN;
  res : IOResult.ReadResults;
  
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
  noError := TRUE;
  WHILE noError AND (index < HIGH(buffer)) AND (* NOT EOF *) DO
    RawIO.Read(file^.cid, ch);
    res := IOResult.ReadResult(file^.cid);
    IF res = IOResult.allRight THEN
      buffer[index] := ch;
      index := index + 1
    ELSE
      noError := FALSE
    END (* IF *)
  END; (* WHILE *)
  
  (* terminate buffer *)
  buffer[index] := NUL;
  
  IF noError THEN
    file^.status := Success
  ELSIF (* again, need to query EOF here *) THEN
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
  res : IOResult.ReadResults;
  
BEGIN
  IF file = NIL THEN
    RETURN
  ELSIF file^.mode # Read THEN
    file^.status := IllegalOperation
  END; (* IF *)
  
  IF (* queue empty *) file^.queue.count = 0 THEN
    RawIO.Read(file^.cid, ch);
    res := IOResult.ReadResult(file^.cid);
    IF res = IOResult.allRight THEN
      octet := ORD(ch);
      file^.status := Success
    ELSIF res = IOResult.endOfInput THEN
      file^.status := ReadBeyondEOF;
      ch := EOT
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
  octet : Octet;
  index : CARDINAL;
  noError : BOOLEAN;
  
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
  
  (* read octets from file *)
  noError := TRUE;
  WHILE noError AND (index < HIGH(buffer)) AND (* NOT EOF *) DO
    RawIO.Read(file^.cid, octet);
    res := IOResult.ReadResult(file^.cid);
    IF res = IOResult.allRight THEN
      buffer[index] := octet;
      index := index + 1
    ELSE
      noError := FALSE
    END (* IF *)
  END; (* WHILE *)
  
  IF noError THEN
    file^.status := Success
  ELSIF (* again, need to query EOF here *) THEN
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
  res : (* Write Result Type ??? *);

BEGIN
  IF file = NIL  THEN
    RETURN
  ELSIF file^.mode = Read THEN
    file^.status := IllegalOperation;
    RETURN
  END; (* IF *)
  
  (* write ch to file *)
  RawIO.Write(file^.cid, ch);
  res := (* how do we get the write result ??? *)
  IF res = (* OK *) THEN
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
  index : CARDINAL;
  noError : BOOLEAN;
  res : (* Write Result Type ??? *);
  
BEGIN
  IF file = NIL  THEN
    RETURN
  ELSIF file^.mode = Read THEN
    file^.status := IllegalOperation
  END; (* IF *)
  
  index := 0;
  noError := TRUE;
  WHILE noError AND index <= HIGH(buffer) AND buffer[index] # NUL DO
    RawIO.Write(file^.cid, buffer[index]);
    res := (* how do we get the write result ??? *)
    IF res = (* OK *) THEN
      index := index + 1
    ELSE (* error *)
      noError := FALSE
    END (* IF *)
  END; (* WHILE *)
  
  IF noError THEN
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
  res : (* Write Result Type ??? *);

BEGIN
  IF file = NIL  THEN
    RETURN
  ELSIF file^.mode = Read THEN
    file^.status := IllegalOperation;
    RETURN
  END; (* IF *)
  
  (* write octet to file *)
  RawIO.Write(file^.cid, octet);
  res := (* how do we get the write result ??? *)
  IF res = (* OK *) THEN
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
  index : CARDINAL;
  noError : BOOLEAN;
  res : (* Write Result Type ??? *);
  
BEGIN
  IF file = NIL  THEN
    RETURN
  ELSIF file^.mode = Read THEN
    file^.status := IllegalOperation
  END; (* IF *)
  
  index := 0;
  noError := TRUE;
  WHILE noError AND index <= HIGH(buffer) DO
    RawIO.Write(file^.cid, buffer[index]);
    res := (* how do we get the write result ??? *)
    IF res = (* OK *) THEN
      index := index + 1
    ELSE (* error *)
      noError := FALSE
    END (* IF *)
  END; (* WHILE *)
  
  IF noError THEN
    file^.status := Success
  ELSE
    file^.status := IOError
  END; (* IF *)
  
  octetsWritten := index
END WriteChars;


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