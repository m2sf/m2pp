(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation. *)

IMPLEMENTATION MODULE BasicFileIO;

(* Basic File IO library for M2PP and M2BSK *)

FROM UnsignedInt IMPORT ULONGINT;


TYPE File; (* OPAQUE *)

TYPE Mode = ( Read, Write, Append );

TYPE Status = ( Success, Failure ); (* TO DO: refine *)


(* Operations *)

(* -----------------------------------------------------------------------
 * Support for an operation depends on the mode in which the file has
 * been opened. Any attempt to carry out an unsupported operation will
 * fail with status Failure. For details, see the table below.
 *
 * operation         | supported in file mode
 *                   | Read    Write   Append
 * ------------------+-----------------------
 * Open              | yes     yes     yes
 * Close             | yes     yes     yes
 * ------------------+-----------------------
 * GetMode           | yes     yes     yes
 * GetStatus         | yes     yes     yes
 * insertBufferEmpty | yes     no*     no*
 * insertBufferFull  | yes     no*     no*
 * eof               | yes     no*     no*
 * ------------------+-----------------------
 * ReadChar          | yes     no      no
 * InsertChar        | yes     no      no
 * ReadChars         | yes     no      no
 * WriteChar         | no      yes     yes
 * WriteChars        | no      yes     yes
 * ------------------+-----------------------
 * key: * = always returns FALSE, result is meaningless.
 * ----------------------------------------------------------------------- *)

(* Open and close *)

PROCEDURE Open
  ( VAR f : File; filename : ARRAY OF CHAR; mode : Mode; VAR s : Status );
(* Opens file filename in mode. Passes file handle in f and status in s.
   If the file does not exist, it will be created when opened in write mode,
   otherwise status failure is passed back in s.  When opening an already
   existing file in write mode, all of its current contents are replaced. *)

BEGIN
  (* TO DO *)
END Open;


PROCEDURE Close ( VAR f : File; s : Status );
(* Closes file associated with file handle f. Passes status in s. *)

BEGIN
  (* TO DO *)
END Close;


(* Introspection *)

PROCEDURE GetMode ( f : File; VAR m : Mode );
(* Passes the mode of file f in m. *)

BEGIN
  (* TO DO *)
END GetMode;


PROCEDURE GetStatus ( f : File; VAR s : Status );
(* Passes the status of the last operation on file f in s. *)

BEGIN
  (* TO DO *)
END GetStatus;


PROCEDURE insertBufferEmpty ( f : File ) : BOOLEAN;
(* Returns TRUE if the internal insert buffer of file f is empty. *)

BEGIN
  (* TO DO *)
END insertBufferEmpty;


PROCEDURE insertBufferFull ( f : File ) : BOOLEAN;
(* Returns TRUE if the internal insert buffer of file f is full. *)

BEGIN
  (* TO DO *)
END insertBufferFull;


PROCEDURE eof ( f : File ) : BOOLEAN;
(* Returns TRUE if the end of file f has been reached, otherwise FALSE. *)

BEGIN
  (* TO DO *)
END eof;


(* Read and unread operations *)

PROCEDURE ReadChar ( f : File; VAR ch : CHAR );
(* If the internal insert buffer of file f is not empty, removes the first
   character from the buffer and returns it in out-parameter ch. Otherwise,
   if the internal insert buffer of file f is empty, reads one character at
   the current reading position of file f and passes it in ch, or ASCII EOT
   if the end of file f had already been reached upon entry into ReadChar. *)

BEGIN
  (* TO DO *)
END ReadChar;


PROCEDURE InsertChar ( f : File; ch : CHAR ); (* Unread *)
(* Inserts character ch into the internal insert buffer of file f unless
   the insert buffer is full. Sets status of file f to Failure if full. *)

BEGIN
  (* TO DO *)
END InsertChar;


PROCEDURE ReadChars
  ( f : File; VAR buffer : ARRAY OF CHAR; VAR charsRead : ULONGINT );
(* If the internal insert buffer of file f is not empty, removes as many
   characters from the insert buffer as will fit into out-parameter buffer
   and copies them to out-parameter buffer.  If and once the internal insert
   buffer is empty, reads contents starting at the current reading position
   of file f into out-parameter buffer until either the pen-ultimate index of
   buffer is written or eof is reached. Out-parameter buffer is then termi-
   nated with ASCII NUL. The number of chars copied is passed in charsRead. *)

BEGIN
  (* TO DO *)
END ReadChars;


(* Write operations *)

PROCEDURE WriteChar ( f : File; ch : CHAR );
(* Writes character ch at the current writing position of file f. *)

BEGIN
  (* TO DO *)
END WriteChar;


PROCEDURE WriteChars
  ( f : File; buffer : ARRAY OF CHAR; VAR charsWritten : ULONGINT );
(* Writes the contents of buffer up to and excluding the first ASCII NUL
   character code at the current writing position to file f. The number of
   characters actually written is passed in charsWritten. *)

BEGIN
  (* TO DO *)
END WriteChars;


END BasicFileIO.