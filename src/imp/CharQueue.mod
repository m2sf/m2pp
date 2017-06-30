(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE CharQueue;

(* Put-Back Character Queue *)


CONST
  NUL = CHR(0);
  QueueSize = 8;


(* ---------------------------------------------------------------------------
 * Hidden queue type
 * ------------------------------------------------------------------------ *)


TYPE Queue = RECORD
  count : CARDINAL;
  char  : ARRAY [0..QueueSize] OF CHAR
END (* Queue *)


(* ---------------------------------------------------------------------------
 * Hidden global queue variable
 * ------------------------------------------------------------------------ *)

VAR
  queue : Queue;


(* Operations *)

(* ---------------------------------------------------------------------------
 * function isEmpty()
 * ---------------------------------------------------------------------------
 * Returns TRUE if the queue is empty, else FALSE.
 * ------------------------------------------------------------------------ *)

PROCEDURE isEmpty ( ) : BOOLEAN;

BEGIN
  RETURN (queue.count = 0)
END isEmpty;


(* ---------------------------------------------------------------------------
 * function isFull()
 * ---------------------------------------------------------------------------
 * Returns TRUE if the queue is full, else FALSE.
 * ------------------------------------------------------------------------ *)

PROCEDURE isFull ( ) : BOOLEAN;

BEGIN
  RETURN (queue.count >= QueueSize)
END isFull;


(* ---------------------------------------------------------------------------
 * procedure Insert(ch)
 * ---------------------------------------------------------------------------
 * Adds ch to the tail of the queue if queue is not full.
 * ------------------------------------------------------------------------ *)

PROCEDURE Insert ( ch : CHAR );

BEGIN
  IF (* not full *) queue.count < QueueSize THEN
    queue.char[queue.count] := ch;
    queue.count := queue.count + 1
  END (* IF *)
END Insert;


(* ---------------------------------------------------------------------------
 * procedure Remove(ch)
 * ---------------------------------------------------------------------------
 * Removes the character at the head of the queue if queue is not empty.
 * Passes the removed character in ch, or NUL if the queue is empty.
 * ------------------------------------------------------------------------ *)

PROCEDURE Remove ( VAR ch : CHAR );

VAR
  index : CARDINAL;
  
BEGIN
  IF (* empty *) queue.count = 0 THEN
    ch := NUL
    
  ELSE (* not empty *)
    ch := queue.char[0];
    index := 0;
    WHILE index < queue.count DO
      queue.char[index] := queue.char[index + 1];
      index := index + 1
    END; (* WHILE *)
    queue.char[index] := NUL;
    queue.count := queue.count - 1
  END (* IF *)
END Remove;


(* ************************************************************************ *
 * Private Operations                                                       *
(* ************************************************************************ *)

(* ---------------------------------------------------------------------------
 * procedure InitQueue
 * ---------------------------------------------------------------------------
 * Initialises the queue.
 * ------------------------------------------------------------------------ *)

PROCEDURE InitQueue;

VAR
  index : CARDINAL;
  
BEGIN
  queue.count := 0;
  FOR index := 0 TO QueueSize DO
    queue.char[index] := NUL
  END (* FOR *)
END InitQueue;


BEGIN
  InitQueue
END CharQueue.