(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE NumStr;

(* Numeric String Conversion Library *)

IMPORT String;
FROM String IMPORT StringT; (* alias for String.String *)


PROCEDURE ToCard
  ( numStr : StringT; VAR value : CARDINAL; VAR status : Status );
(* Converts the value represented by numStr to type CARDINAL. *)

VAR
  ch : CHAR;
  overflow : BOOLEAN;
  index, minIndex, digitIndex,
  accumulator, digitWeight, digitValue : CARDINAL;
  
BEGIN
  (* check sign *)
  ch := String.charAtIndex(numStr, 0);
  minIndex := 0;
  IF ch = '+' THEN
    minIndex := 1
  ELSIF ch = '-' THEN
    status := Underflow;
    RETURN
  END; (* IF *)
  
  (* get the index for the right most character *)
  digitIndex := String.length(numStr);
  IF digitIndex > 0 THEN
    digitIndex := digitIndex - 1
  END; (* IF *)
      
  accumulator := 0;
  digitWeight := 1;
  
  (* iterate over all chars from right to left *)
  LOOP
    (* verify character is a digit *)
    ch := String.charAtIndex(numStr, digitIndex);
    IF (ch >= '0') AND (ch <= '9') THEN
      digitValue := digitWeight * (ORD(ch) - ORD("0"))
    ELSE (* not a number *)
      status := NaN;
      RETURN
    END; (* IF *)
    
    (* add this digit's value to accumulator *)
    addCard(accumulator, digitValue, overflow);
    IF overflow THEN
      status := Overflow;
      RETURN
    END; (* IF *)
    
    (* set up next iteration *)
    IF (index > minIndex) THEN
      (* calculate weight for next digit *)
      IF MAX(CARDINAL) DIV 10 > digitWeight THEN
        digitWeight := digitWeight * 10
      ELSE
        status := Overflow;
        RETURN
      END; (* IF *)
      
      (* calculate index for next digit *)
      digitIndex := digitIndex - 1
    ELSE
      status := Success;
      EXIT
    END (* IF *)
  END; (* LOOP *)
  
  value := accumulator
END ToCard;


PROCEDURE ToInt
  ( numStr : StringT; VAR value : INTEGER; VAR status : Status );
(* Converts the value represented by numStr to type INTEGER. *)

VAR
  ch : CHAR;
  overflow, negative : BOOLEAN;
  index, minIndex, digitIndex : CARDINAL;
  accumulator, digitWeight, digitValue : INTEGER;
  
BEGIN
  (* check sign *)
  ch := String.charAtIndex(numStr, 0);
  minIndex := 0;
  negative := FALSE;
  IF ch = '+' THEN
    minIndex := 1;
  ELSIF ch = '-' THEN
    minIndex := 1;
    negative := TRUE
  END; (* IF *)
  
  (* get the index for the right most character *)
  digitIndex := String.length(numStr);
  IF digitIndex > 0 THEN
    digitIndex := digitIndex - 1
  END; (* IF *)
  
  accumulator := 0;
  digitWeight := 1;
  
  (* iterate over all chars from right to left *)
  LOOP
    (* verify character is a digit *)
    ch := String.charAtIndex(numStr, digitIndex);
    IF (ch >= '0') AND (ch <= '9') THEN
      digitValue := digitWeight * VAL(INTEGER, ORD(ch) - ORD("0"))
    ELSE (* not a number *)
      status := NaN;
      RETURN
    END; (* IF *)
    
    (* add this digit's value to accumulator *)
    addInt(accumulator, digitValue, overflow);
    IF overflow THEN
      IF negative THEN
        status := Underflow
      ELSE
        status := Overflow
      END;
      RETURN
    END; (* IF *)
    
    (* set up next iteration *)
    IF (index > minIndex) THEN
      (* calculate weight for next digit *)
      IF MAX(INTEGER) DIV 10 > digitWeight THEN
        digitWeight := digitWeight * 10
      ELSE
        IF negative THEN
          status := Underflow
        ELSE
          status := Overflow
        END;
        RETURN
      END; (* IF *)
      
      (* calculate index for next digit *)
      digitIndex := digitIndex - 1
    ELSE
      status := Success;
      EXIT
    END (* IF *)
  END; (* LOOP *)
  
  value := accumulator
END ToInt;


(* ************************************************************************ *
 * Private Operations                                                       *
 * ************************************************************************ *)

(* ---------------------------------------------------------------------------
 * function addCard(n, m, overflow)
 * ---------------------------------------------------------------------------
 * If n+m does not overflow, n+m is passed back in n and FALSE in overflow.
 * If n+m overflows, n is left unmodified and TRUE is passed back in overflow.
 * ------------------------------------------------------------------------ *)

PROCEDURE addCard ( VAR n : CARDINAL; m : CARDINAL; VAR overflow : BOOLEAN );

BEGIN
  IF (m > 0) AND (n > MAX(CARDINAL) - m) THEN
    overflow := TRUE
  ELSE
    overflow := FALSE;
    n := n + m
  END
END addCard;


(* ---------------------------------------------------------------------------
 * function addInt(i, j, overflow)
 * ---------------------------------------------------------------------------
 * If i+j does not overflow, i+j is passed back in i and FALSE in overflow.
 * If i+j overflows, i is left unmodified and TRUE is passed back in overflow.
 * ------------------------------------------------------------------------ *)

PROCEDURE addInt ( VAR i : INTEGER; j : INTEGER; VAR overflow : BOOLEAN );

BEGIN
  IF (i > 0) AND (i > MAX(INTEGER) - j) THEN
    overflow := TRUE
  ELSE
    overflow := FALSE;
    i := i + j
  END
END addInt;


END NumStr.