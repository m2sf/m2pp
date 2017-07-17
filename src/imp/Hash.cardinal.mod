(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation. *)

IMPLEMENTATION MODULE Hash; (* CARDINAL version *)

(* General Purpose 32-bit Hash Function *)

IMPORT Terminal; (* for abort message *)


CONST
  HashBitwidth = 32;
  Pow2Max = 2*1024*1024*1024; (* pow2(HashBitwidth-1) = pow2(31) *)


(* ---------------------------------------------------------------------------
 * compile time calculation of the bit width of type CARDINAL
 * ------------------------------------------------------------------------ *)

  CardBitwidth = (* CARDINAL must be at least 32 bits wide *)
    8*ORD(BW8) + 16*ORD(BW16) + 24*ORD(BW24) + 32*ORD(BW32) +
    40*ORD(BW40) + 48*ORD(BW48) + 56*ORD(BW56) + 64*ORD(BW64);


(* ---------------------------------------------------------------------------
 * function:  Hash.valueForNextChar( hash, ch )
 * ------------------------------------------------------------------------ *)

PROCEDURE valueForNextChar ( hash : Key; ch : CHAR ) : Key;

BEGIN
  RETURN Key(ORD(ch) + SHL(hash, 6) + SHL(hash, 16) - hash
END valueForNextChar;


(* ---------------------------------------------------------------------------
 * function:  Hash.finalValue( hash )
 * ------------------------------------------------------------------------ *)

PROCEDURE finalValue ( hash : Key ) : Key;

VAR
  pow2max : CARDINAL;
  
BEGIN
  (* Clear bit 31 and above in hash value *)
  IF hash >= Pow2Max THEN
    IF CardBitwidth > HashBitwidth THEN
      ClearBitsInclAndAbove(hash, HashBitwidth-1)
    ELSE
      hash := hash - Pow2Max
  END; (* IF *)
  
  RETURN hash
END finalValue;


(* ---------------------------------------------------------------------------
 * function:  Hash.valueForArray( array )
 * ------------------------------------------------------------------------ *)

PROCEDURE valueForArray ( VAR (* CONST *) array : ARRAY OF CHAR ) : Key;

CONST
  NUL = CHR(0);
  
VAR
  ch : CHAR;
  hash : Key;
  index : CARDINAL;
  
BEGIN
  index := 0;
  hash := initialValue;
  
  ch := array[index]
  WHILE (ch # NUL) AND (index < HIGH(array)) DO
    hash := Key(ORD(ch)) + SHL(hash, 6) + SHL(hash, 16) - hash;
    index := index + 1;
    ch := array[index]
  END; (* WHILE *)
  
  (* Clear bit 31 and above in hash value *)
  IF hash >= Pow2Max THEN
    IF CardBitwidth > HashBitwidth THEN
      ClearBitsInclAndAbove(hash, HashBitwidth-1)
    ELSE
      hash := hash - Pow2Max
  END; (* IF *)
  
  RETURN hash
END valueForArray;


(* ************************************************************************ *
 * Private Operations                                                       *
 * ************************************************************************ *)

CONST
  MaxCardDivPow2Of8 = MAX(CARDINAL) DIV 256;
  MaxCardDivPow2Of16 = MaxCardDivPow2Of8 DIV 256;
  MaxCardDivPow2Of24 = MaxCardDivPow2Of16 DIV 256;
  MaxCardDivPow2Of32 = MaxCardDivPow2Of24 DIV 256;
  MaxCardDivPow2Of40 = MaxCardDivPow2Of32 DIV 256;
  MaxCardDivPow2Of48 = MaxCardDivPow2Of40 DIV 256;
  MaxCardDivPow2Of56 = MaxCardDivPow2Of48 DIV 256;
  MaxCardDivPow2Of64 = MaxCardDivPow2Of56 DIV 256;
    
  BW8 = MAX(CARDINAL) <= 255;
  BW16 = NOT BW8 AND (MaxCardDivPow2Of8 <= 255);
  BW24 = NOT BW16 AND (MaxCardDivPow2Of16 <= 255);
  BW32 = NOT BW24 AND (MaxCardDivPow2Of24 <= 255);
  BW40 = NOT BW32 AND (MaxCardDivPow2Of32 <= 255);
  BW48 = NOT BW40 AND (MaxCardDivPow2Of40 <= 255);
  BW56 = NOT BW48 AND (MaxCardDivPow2Of48 <= 255);
  BW64 = NOT BW56 AND (MaxCardDivPow2Of56 <= 255);
  

(* ---------------------------------------------------------------------------
 * function: SHL( hash, shiftFactor )
 * ---------------------------------------------------------------------------
 * Returns the value of hash shifted left by shiftFactor.
 * ------------------------------------------------------------------------ *)

PROCEDURE SHL ( hash : Key; shiftFactor : CARDINAL ) : Key;

VAR
  pivotalBit : CARDINAL;
  
BEGIN
  (* shifting by HashBitwidth and more produces all zeroes *)
  IF shiftFactor > HashBitwidth-1 THEN
    RETURN 0
  END; (* IF *)
  
  (* bit at position CardBitwidth-shiftFactor is pivotal *)
  pivotalBit := CardBitwidth - shiftFactor;
  
  (* clear bits including and above pivotal bit to avoid overflow *)
  IF hash >= pow2(pivotalBit) THEN
    ClearBitsInclAndAbove(hash, pivotalBit)
  END; (* IF *)
  
  (* shift left safely *)
  RETURN hash * pow2[shiftFactor]
END SHL;


(* ---------------------------------------------------------------------------
 * procedure: ClearBitsInclAndAbove( value, lowestBitToClear )
 * ---------------------------------------------------------------------------
 * Clears all bits including and above bit at position lowestBitToClear.
 * ------------------------------------------------------------------------ *)

TYPE BitIndex = CARDINAL [0..HashBitwidth-1];

PROCEDURE ClearBitsInclAndAbove
  ( VAR hash : Key; lowestBitToClear : BitIndex );

VAR
  mask : Key;
  bitToClear : CARDINAL;
  
BEGIN
  (* shift lower bits out to the right *)
  mask := hash DIV lowestBitToClear+1;
  
  (* shift them back, thereby clearing the low bits *)
  mask := mask * pow2[lowestBitToClear+1];
  
  (* subtract the mask, thereby clearing the high bits *)
  hash := hash - mask;
END ClearBitsInclAndAbove;


(* ---------------------------------------------------------------------------
 * array pow2[0..31]
 * ---------------------------------------------------------------------------
 * Pre-calculated powers of 2 for n in [0..31]
 * ------------------------------------------------------------------------ *)

VAR
  pow2 : ARRAY [0..HashBitwidth-1] OF CARDINAL;

PROCEDURE InitPow2Table;

VAR
  index : CARDINAL;

BEGIN
  pow2[0] := 1;
  FOR index := 1 TO HashBitwidth-1 DO
    pow2[index] := 2 * pow2[index-1]
  END (* FOR *)
END InitPow2Table;


BEGIN (* Hash *)
  (* abort if CARDINAL is not at least 32 bits wide *)
  IF CardBitwidth < HashBitwidth THEN
    Terminal.WriteString
      ("Library Hash requires CARDINALs of at least 32 bits.");
    Terminal.WriteLn;
    HALT
  END; (* IF *)
  
  (* initialise pow2 table *)
  InitPow2Table
END Hash.