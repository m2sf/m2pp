(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation. *)

IMPLEMENTATION MODULE Hash; (* CARDINAL version *)

(* General Purpose 32-bit Hash Function *)

IMPORT Terminal; (* for abort message *)


CONST
  KeyBitwidth = 32; (* must not exceed bit width of type CARDINAL *)


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
 * compile time calculation of the bit width of type CARDINAL
 * ------------------------------------------------------------------------ *)

  CardBitwidth =
    8*ORD(BW8) + 16*ORD(BW16) + 24*ORD(BW24) + 32*ORD(BW32) +
    40*ORD(BW40) + 48*ORD(BW48) + 56*ORD(BW56) + 64*ORD(BW64);


(* ---------------------------------------------------------------------------
 * index type for bit addressing
 * ------------------------------------------------------------------------ *)

TYPE BitIndex = CARDINAL [0..CardBitwidth-1];


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
  RETURN ORD(ch) + SHL(hash, 6) + SHL(hash, 16) - hash
END valueForNextChar;


(* ---------------------------------------------------------------------------
 * function:  Hash.finalValue( hash )
 * ------------------------------------------------------------------------ *)

PROCEDURE finalValue ( hash : Key ) : Key;

BEGIN
  (* Clear bits [MSB..KeyBitwidth-1] in hash value *)
  IF hash >= KeyMSBWeight THEN
    IF CardBitwidth > KeyBitwidth THEN
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
    hash := ORD(ch) + SHL(hash, 6) + SHL(hash, 16) - hash;
    index := index + 1;
    ch := array[index]
  END; (* WHILE *)
  
  (* Clear bits [MSB..KeyBitwidth-1] in hash value *)
  IF hash >= KeyMSBWeight THEN
    IF CardBitwidth > KeyBitwidth THEN
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
  
  (* bit at position CardBitwidth-shiftFactor is pivotal *)
  pivotalBit := CardBitwidth - shiftFactor;
  
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
  mask := hash DIV lowestBitToClear+1;
  
  (* shift them back, thereby clearing the low bits *)
  mask := mask * pow2[lowestBitToClear+1];
  
  (* subtract the mask, thereby clearing the high bits *)
  hash := hash - mask
END ClearBitsInclAndAbove;


(* ---------------------------------------------------------------------------
 * array pow2[]
 * ---------------------------------------------------------------------------
 * Pre-calculated powers of 2 for n in [0..CardBitwidth-1]
 * ------------------------------------------------------------------------ *)

VAR
  pow2 : ARRAY [0..MAX(BitIndex)] OF CARDINAL;


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
  (* abort if CARDINAL is not at least 32 bits wide *)
  IF CardBitwidth < KeyBitwidth THEN
    Terminal.WriteString
      ("Library Hash requires CARDINALs of at least 32 bits.");
    Terminal.WriteLn;
    HALT
  END; (* IF *)
  
  (* initialise pow2 table *)
  InitPow2Table
END Hash.