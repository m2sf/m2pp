(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation. *)

IMPLEMENTATION MODULE Hash; (* LONGINT version *)

(* General Purpose 31-bit Hash Function *)

IMPORT Terminal; (* for abort message *)


CONST
  KeyBitwidth = 31; (* must be less than bit width of type LONGINT *)


(* ---------------------------------------------------------------------------
 * weight of MSB of type Hash.Key = pow2(KeyBitwidth-1)
 * ------------------------------------------------------------------------ *)

  KeyMSBWeight =
    ORD(KeyBitwidth=1) * 1 +
    ORD(KeyBitwidth=2) * 2 +
    ORD(KeyBitwidth=3) * 4 +
    ORD(KeyBitwidth=4) * 8 +
    ORD(KeyBitwidth=5) * 16 +
    ORD(KeyBitwidth=6) * 32 +
    ORD(KeyBitwidth=7) * 64 +
    ORD(KeyBitwidth=8) * 128 +
    ORD(KeyBitwidth=9) * 256 +
    ORD(KeyBitwidth=10) * 256 * 2 +
    ORD(KeyBitwidth=11) * 256 * 4 +
    ORD(KeyBitwidth=12) * 256 * 8 +
    ORD(KeyBitwidth=13) * 256 * 16 +
    ORD(KeyBitwidth=14) * 256 * 32 +
    ORD(KeyBitwidth=15) * 256 * 64 +
    ORD(KeyBitwidth=16) * 256 * 128 +
    ORD(KeyBitwidth=17) * 256 * 256 +
    ORD(KeyBitwidth=18) * 256 * 256 * 2 +
    ORD(KeyBitwidth=19) * 256 * 256 * 4 +
    ORD(KeyBitwidth=20) * 256 * 256 * 8 +
    ORD(KeyBitwidth=21) * 256 * 256 * 16 +
    ORD(KeyBitwidth=22) * 256 * 256 * 32 +
    ORD(KeyBitwidth=23) * 256 * 256 * 64 +
    ORD(KeyBitwidth=24) * 256 * 256 * 128 +
    ORD(KeyBitwidth=25) * 256 * 256 * 256 +
    ORD(KeyBitwidth=26) * 256 * 256 * 256 * 2 +
    ORD(KeyBitwidth=27) * 256 * 256 * 256 * 4 +
    ORD(KeyBitwidth=28) * 256 * 256 * 256 * 8 +
    ORD(KeyBitwidth=29) * 256 * 256 * 256 * 16 +
    ORD(KeyBitwidth=30) * 256 * 256 * 256 * 32 +
    ORD(KeyBitwidth=31) * 256 * 256 * 256 * 64 +
    ORD(KeyBitwidth=32) * 256 * 256 * 256 * 128 +
    ORD(KeyBitwidth=33) * 256 * 256 * 256 * 256 +
    ORD(KeyBitwidth=34) * 256 * 256 * 256 * 256 * 2 +
    ORD(KeyBitwidth=35) * 256 * 256 * 256 * 256 * 4 +
    ORD(KeyBitwidth=36) * 256 * 256 * 256 * 256 * 8 +
    ORD(KeyBitwidth=37) * 256 * 256 * 256 * 256 * 16 +
    ORD(KeyBitwidth=38) * 256 * 256 * 256 * 256 * 32 +
    ORD(KeyBitwidth=39) * 256 * 256 * 256 * 256 * 64 +
    ORD(KeyBitwidth=40) * 256 * 256 * 256 * 256 * 128 +
    ORD(KeyBitwidth=41) * 256 * 256 * 256 * 256 * 256 +
    ORD(KeyBitwidth=42) * 256 * 256 * 256 * 256 * 256 * 2 +
    ORD(KeyBitwidth=43) * 256 * 256 * 256 * 256 * 256 * 4 +
    ORD(KeyBitwidth=44) * 256 * 256 * 256 * 256 * 256 * 8 +
    ORD(KeyBitwidth=45) * 256 * 256 * 256 * 256 * 256 * 16 +
    ORD(KeyBitwidth=46) * 256 * 256 * 256 * 256 * 256 * 32 +
    ORD(KeyBitwidth=47) * 256 * 256 * 256 * 256 * 256 * 64 +
    ORD(KeyBitwidth=48) * 256 * 256 * 256 * 256 * 256 * 128 +
    ORD(KeyBitwidth=49) * 256 * 256 * 256 * 256 * 256 * 256 +
    ORD(KeyBitwidth=50) * 256 * 256 * 256 * 256 * 256 * 256 * 2 +
    ORD(KeyBitwidth=51) * 256 * 256 * 256 * 256 * 256 * 256 * 4 +
    ORD(KeyBitwidth=52) * 256 * 256 * 256 * 256 * 256 * 256 * 8 +
    ORD(KeyBitwidth=53) * 256 * 256 * 256 * 256 * 256 * 256 * 16 +
    ORD(KeyBitwidth=54) * 256 * 256 * 256 * 256 * 256 * 256 * 32 +
    ORD(KeyBitwidth=55) * 256 * 256 * 256 * 256 * 256 * 256 * 64 +
    ORD(KeyBitwidth=56) * 256 * 256 * 256 * 256 * 256 * 256 * 128 +
    ORD(KeyBitwidth=57) * 256 * 256 * 256 * 256 * 256 * 256 * 256 +
    ORD(KeyBitwidth=58) * 256 * 256 * 256 * 256 * 256 * 256 * 256 * 2 +
    ORD(KeyBitwidth=59) * 256 * 256 * 256 * 256 * 256 * 256 * 256 * 4 +
    ORD(KeyBitwidth=60) * 256 * 256 * 256 * 256 * 256 * 256 * 256 * 8 +
    ORD(KeyBitwidth=61) * 256 * 256 * 256 * 256 * 256 * 256 * 256 * 16 +
    ORD(KeyBitwidth=62) * 256 * 256 * 256 * 256 * 256 * 256 * 256 * 32 +
    ORD(KeyBitwidth=63) * 256 * 256 * 256 * 256 * 256 * 256 * 256 * 64 +
    ORD(KeyBitwidth=64) * 256 * 256 * 256 * 256 * 256 * 256 * 256 * 128;


(* ---------------------------------------------------------------------------
 * compile time calculation of the bit width of type LONGINT
 * ------------------------------------------------------------------------ *)

  MaxLongIntDivPow2Of8 = MAX(LONGINT) DIV 256;
  MaxLongIntDivPow2Of16 = MaxLongIntDivPow2Of8 DIV 256;
  MaxLongIntDivPow2Of24 = MaxLongIntDivPow2Of16 DIV 256;
  MaxLongIntDivPow2Of32 = MaxLongIntDivPow2Of24 DIV 256;
  MaxLongIntDivPow2Of40 = MaxLongIntDivPow2Of32 DIV 256;
  MaxLongIntDivPow2Of48 = MaxLongIntDivPow2Of40 DIV 256;
  MaxLongIntDivPow2Of56 = MaxLongIntDivPow2Of48 DIV 256;
  MaxLongIntDivPow2Of64  = MaxLongIntDivPow2Of56 DIV 256;
  MaxLongIntDivPow2Of72  = MaxLongIntDivPow2Of64 DIV 256;
  MaxLongIntDivPow2Of80  = MaxLongIntDivPow2Of72 DIV 256;
  MaxLongIntDivPow2Of88  = MaxLongIntDivPow2Of80 DIV 256;
  MaxLongIntDivPow2Of96  = MaxLongIntDivPow2Of88 DIV 256;
  MaxLongIntDivPow2Of104 = MaxLongIntDivPow2Of96 DIV 256;
  MaxLongIntDivPow2Of112 = MaxLongIntDivPow2Of104 DIV 256;
  MaxLongIntDivPow2Of120 = MaxLongIntDivPow2Of112 DIV 256;
  
  BW8 = (MAX(LONGINT) <= 127);
  BW16 = (MaxLongIntDivPow2Of8 > 0) AND (MaxLongIntDivPow2Of8 <= 127);
  BW24 = (MaxLongIntDivPow2Of16 > 0) AND (MaxLongIntDivPow2Of16 <= 127);
  BW32 = (MaxLongIntDivPow2Of24 > 0) AND (MaxLongIntDivPow2Of24 <= 127);
  BW40 = (MaxLongIntDivPow2Of32 > 0) AND (MaxLongIntDivPow2Of32 <= 127);
  BW48 = (MaxLongIntDivPow2Of40 > 0) AND (MaxLongIntDivPow2Of40 <= 127);
  BW56 = (MaxLongIntDivPow2Of48 > 0) AND (MaxLongIntDivPow2Of48 <= 127);
  BW64 = (MaxLongIntDivPow2Of56 > 0) AND (MaxLongIntDivPow2Of56 <= 127);
  BW72  = (MaxLongIntDivPow2Of64 > 0) AND (MaxLongIntDivPow2Of64 <= 127);
  BW80  = (MaxLongIntDivPow2Of72 > 0) AND (MaxLongIntDivPow2Of72 <= 127);
  BW88  = (MaxLongIntDivPow2Of80 > 0) AND (MaxLongIntDivPow2Of80 <= 127);
  BW96  = (MaxLongIntDivPow2Of88 > 0) AND (MaxLongIntDivPow2Of88 <= 127);
  BW104 = (MaxLongIntDivPow2Of96 > 0) AND (MaxLongIntDivPow2Of96 <= 127);
  BW112 = (MaxLongIntDivPow2Of104 > 0) AND (MaxLongIntDivPow2Of104 <= 127);
  BW120 = (MaxLongIntDivPow2Of112 > 0) AND (MaxLongIntDivPow2Of112 <= 127);
  BW128 = (MaxLongIntDivPow2Of120 > 0) AND (MaxLongIntDivPow2Of120 <= 127);
  
  LongIntBitwidth =
    8*ORD(BW8) + 16*ORD(BW16) + 24*ORD(BW24) + 32*ORD(BW32) +
    40*ORD(BW40) + 48*ORD(BW48) + 56*ORD(BW56) + 64*ORD(BW64)
    72*ORD(BW72) + 80*ORD(BW80) + 88*ORD(BW88) + 96*ORD(BW96) +
    104*ORD(BW104) + 112*ORD(BW112) + 120*ORD(BW120) + 128*ORD(BW128);


(* ---------------------------------------------------------------------------
 * index type for bit addressing
 * ------------------------------------------------------------------------ *)

TYPE BitIndex = CARDINAL [0..LongIntBitwidth-1];


(* ---------------------------------------------------------------------------
 * function Hash.initialValue()
 * ------------------------------------------------------------------------ *)

PROCEDURE initialValue ( ) : Key;

BEGIN
  RETURN 0
END initalValue;


(* ---------------------------------------------------------------------------
 * function:  Hash.valueForNextChar( hash, ch )
 * ------------------------------------------------------------------------ *)

PROCEDURE valueForNextChar ( hash : Key; ch : CHAR ) : Key;

BEGIN
  RETURN VAL(LONGINT, ch) + SHL(hash, 6) + SHL(hash, 16) - hash
END valueForNextChar;


(* ---------------------------------------------------------------------------
 * function:  Hash.finalValue( hash )
 * ------------------------------------------------------------------------ *)

PROCEDURE finalValue ( hash : Key ) : Key;

BEGIN
  (* Clear bits [MSB..KeyBitwidth-1] in hash value *)
  IF hash >= KeyMSBWeight THEN
    IF LongIntBitwidth > KeyBitwidth THEN
      ClearBitsInclAndAbove(hash, KeyBitwidth-1)
    ELSE
      hash := hash - KeyMSBWeight
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
  index : CARDINAL; (* char index *)
  
BEGIN
  index := 0;
  hash := initialValue();
  
  ch := array[index]
  WHILE (ch # NUL) AND (index < HIGH(array)) DO
    hash := VAL(LONGINT, ch) + SHL(hash, 6) + SHL(hash, 16) - hash;
    index := index + 1;
    ch := array[index]
  END; (* WHILE *)
  
  (* Clear bits [MSB..KeyBitwidth-1] in hash value *)
  IF hash >= KeyMSBWeight THEN
    IF LongIntBitwidth > KeyBitwidth THEN
      ClearBitsInclAndAbove(hash, KeyBitwidth-1)
    ELSE
      hash := hash - KeyMSBWeight
  END; (* IF *)
  
  RETURN hash
END valueForArray;


(* ************************************************************************ *
 * Private Operations                                                       *
 * ************************************************************************ *)

CONST
  MaxLongIntDivPow2Of8 = MAX(LONGINT) DIV 256;
  MaxLongIntDivPow2Of16 = MaxLongIntDivPow2Of8 DIV 256;
  MaxLongIntDivPow2Of24 = MaxLongIntDivPow2Of16 DIV 256;
  MaxLongIntDivPow2Of32 = MaxLongIntDivPow2Of24 DIV 256;
  MaxLongIntDivPow2Of40 = MaxLongIntDivPow2Of32 DIV 256;
  MaxLongIntDivPow2Of48 = MaxLongIntDivPow2Of40 DIV 256;
  MaxLongIntDivPow2Of56 = MaxLongIntDivPow2Of48 DIV 256;
  MaxLongIntDivPow2Of64 = MaxLongIntDivPow2Of56 DIV 256;
    
  BW8 = MAX(LONGINT) <= 127;
  BW16 = NOT BW8 AND (MaxLongIntDivPow2Of8 <= 127);
  BW24 = NOT BW16 AND (MaxLongIntDivPow2Of16 <= 127);
  BW32 = NOT BW24 AND (MaxLongIntDivPow2Of24 <= 127);
  BW40 = NOT BW32 AND (MaxLongIntDivPow2Of32 <= 127);
  BW48 = NOT BW40 AND (MaxLongIntDivPow2Of40 <= 127);
  BW56 = NOT BW48 AND (MaxLongIntDivPow2Of48 <= 127);
  BW64 = NOT BW56 AND (MaxLongIntDivPow2Of56 <= 127);
  

(* ---------------------------------------------------------------------------
 * function: shl( hash, shiftFactor )
 * ---------------------------------------------------------------------------
 * Returns the value of hash shifted left by shiftFactor. Ensures no overflow.
 * ------------------------------------------------------------------------ *)

PROCEDURE SHL ( hash : Key; shiftFactor : BitIndex ) : Key;

VAR
  pivotalBit : BitIndex;
  
BEGIN
  (* shifting by KeyBitwidth and more produces all zeroes *)
  IF shiftFactor > KeyBitwidth-1 THEN
    RETURN 0
  END; (* IF *)
  
  (* bit at position LongIntBitwidth-shiftFactor is pivotal *)
  pivotalBit := LongIntBitwidth - shiftFactor;
  
  (* clear bits including and above pivotal bit to avoid overflow *)
  IF hash >= pow2[pivotalBit] THEN
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

PROCEDURE ClearBitsInclAndAbove
  ( VAR hash : Key; lowestBitToClear : BitIndex );

VAR
  mask : Key;
  bitToClear : BitIndex;
  
BEGIN
  (* shift lower bits out to the right *)
  mask := hash DIV VAL(LONGINT, lowestBitToClear+1);
  
  (* shift them back, thereby clearing the low bits *)
  mask := mask * pow2[lowestBitToClear+1];
  
  (* subtract the mask, thereby clearing the high bits *)
  hash := hash - mask
END ClearBitsInclAndAbove;


(* ---------------------------------------------------------------------------
 * array pow2[]
 * ---------------------------------------------------------------------------
 * Pre-calculated powers of 2 for n in [0..LongIntBitwidth-2]
 * ------------------------------------------------------------------------ *)

VAR
  pow2 : ARRAY [0..MAX(BitIndex)] OF LONGINT;


PROCEDURE InitPow2Table;

VAR
  index : BitIndex;

BEGIN
  pow2[0] := 1;
  FOR index := 1 TO MAX(BitIndex) DO
    pow2[index] := 2 * pow2[index-1]
  END (* FOR *)
END InitPow2Table;


BEGIN (* Hash *)
  (* abort if KeyBitwidth width equals or exceeds bit width of type LONGINT *)
  IF KeyBitwidth >= LongIntBitwidth THEN
    Terminal.WriteString
      ("Hash.mod: KeyBitwidth equals or exceeds bit width of type LONGINT.");
    Terminal.WriteLn;
    Terminal.WriteString("program aborted.");
    Terminal.WriteLn;
    HALT
  END; (* IF *)
  
  (* initialise pow2 table *)
  InitPow2Table
END Hash.