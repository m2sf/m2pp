(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation. *)

IMPLEMENTATION MODULE CardMath;

(* Cardinal Math library *)


(* Cardinal bitwidth calculation for up to 128 bits *)

CONST
  MaxCardDivPow2Of8   = MAX(CARDINAL) DIV 256;
  MaxCardDivPow2Of16  = MaxCardDivPow2Of8 DIV 256;
  MaxCardDivPow2Of24  = MaxCardDivPow2Of16 DIV 256;
  MaxCardDivPow2Of32  = MaxCardDivPow2Of24 DIV 256;
  MaxCardDivPow2Of40  = MaxCardDivPow2Of32 DIV 256;
  MaxCardDivPow2Of48  = MaxCardDivPow2Of40 DIV 256;
  MaxCardDivPow2Of56  = MaxCardDivPow2Of48 DIV 256;
  MaxCardDivPow2Of64  = MaxCardDivPow2Of56 DIV 256;
  MaxCardDivPow2Of72  = MaxCardDivPow2Of64 DIV 256;
  MaxCardDivPow2Of80  = MaxCardDivPow2Of72 DIV 256;
  MaxCardDivPow2Of88  = MaxCardDivPow2Of80 DIV 256;
  MaxCardDivPow2Of96  = MaxCardDivPow2Of88 DIV 256;
  MaxCardDivPow2Of104 = MaxCardDivPow2Of96 DIV 256;
  MaxCardDivPow2Of112 = MaxCardDivPow2Of104 DIV 256;
  MaxCardDivPow2Of120 = MaxCardDivPow2Of112 DIV 256;
  
  BW8   = (MAX(CARDINAL) <= 255);
  BW16  = (MaxCardDivPow2Of8 > 0) AND (MaxCardDivPow2Of8 <= 255);
  BW24  = (MaxCardDivPow2Of16 > 0) AND (MaxCardDivPow2Of16 <= 255);
  BW32  = (MaxCardDivPow2Of24 > 0) AND (MaxCardDivPow2Of24 <= 255);
  BW40  = (MaxCardDivPow2Of32 > 0) AND (MaxCardDivPow2Of32 <= 255);
  BW48  = (MaxCardDivPow2Of40 > 0) AND (MaxCardDivPow2Of40 <= 255);
  BW56  = (MaxCardDivPow2Of48 > 0) AND (MaxCardDivPow2Of48 <= 255);
  BW64  = (MaxCardDivPow2Of56 > 0) AND (MaxCardDivPow2Of56 <= 255);
  BW72  = (MaxCardDivPow2Of64 > 0) AND (MaxCardDivPow2Of64 <= 255);
  BW80  = (MaxCardDivPow2Of72 > 0) AND (MaxCardDivPow2Of72 <= 255);
  BW88  = (MaxCardDivPow2Of80 > 0) AND (MaxCardDivPow2Of80 <= 255);
  BW96  = (MaxCardDivPow2Of88 > 0) AND (MaxCardDivPow2Of88 <= 255);
  BW104 = (MaxCardDivPow2Of96 > 0) AND (MaxCardDivPow2Of96 <= 255);
  BW112 = (MaxCardDivPow2Of104 > 0) AND (MaxCardDivPow2Of104 <= 255);
  BW120 = (MaxCardDivPow2Of112 > 0) AND (MaxCardDivPow2Of112 <= 255);
  BW128 = (MaxCardDivPow2Of120 > 0) AND (MaxCardDivPow2Of120 <= 255);
  
  Bitwidth =
    8*ORD(BW8) + 16*ORD(BW16) + 24*ORD(BW24) + 32*ORD(BW32) +
    40*ORD(BW40) + 48*ORD(BW48) + 56*ORD(BW56) + 64*ORD(BW64) +
    72*ORD(BW72) + 80*ORD(BW80) + 88*ORD(BW88) + 96*ORD(BW96) +
    104*ORD(BW104) + 112*ORD(BW112) + 120*ORD(BW120) + 128*ORD(BW128);

  DecDigits =
    3*ORD(BW8) + 5*ORD(BW16) + 8*ORD(BW24) + 10*ORD(BW32) +
    13*ORD(BW40) + 15*ORD(BW48) + 17*ORD(BW56) + 20*ORD(BW64) +
    22*ORD(BW72) + 25*ORD(BW80) + 27*ORD(BW88) + 29*ORD(BW96) +
    32*ORD(BW104) + 34*ORD(BW112) + 37*ORD(BW120) + 39*ORD(BW128);


(* Math operations *)

(* --------------------------------------------------------------------------
 * function abs(i)
 * --------------------------------------------------------------------------
 * Returns the absolute CARDINAL value of INTEGER i
 * ----------------------------------------------------------------------- *)

PROCEDURE abs ( i : INTEGER ) : CARDINAL;

BEGIN
  IF i = MIN(INTEGER) THEN
    RETURN powerOf2[Bitwidth-1]
  ELSE
    RETURN VAL(CARDINAL, ABS(i))
  END (* IF *)
END abs;


(* --------------------------------------------------------------------------
 * function pow2(n)
 * --------------------------------------------------------------------------
 * Returns the power of 2 for argument n
 * ----------------------------------------------------------------------- *)

PROCEDURE pow2 ( n : CARDINAL ) : CARDINAL;

BEGIN
  RETURN powerOf2[n]
END pow2;


(* --------------------------------------------------------------------------
 * function log2(n)
 * --------------------------------------------------------------------------
 * Returns the integral part of the logarithm of 2 for argument n.
 * ----------------------------------------------------------------------- *)

PROCEDURE log2 ( n : CARDINAL ) : CARDINAL;

VAR
  r, k : CARDINAL;
  
BEGIN
  (* bail out if n is zero *)
  IF n = 0 THEN HALT END;
  
  r := 0;
  
  (* any size of CARDINAL *)
  k := Bitwidth DIV 2;
  WHILE k > 0 DO
    
    IF n >= pow2(k) THEN
      r := r + k;
      n := shr(n, k)
    END; (* IF *)
    
    k := k DIV 2
  END; (* WHILE *)
  
  RETURN r
END log2;


(* --------------------------------------------------------------------------
 * function pow10(n)
 * --------------------------------------------------------------------------
 * Returns the power of 10 for argument n
 * ----------------------------------------------------------------------- *)

PROCEDURE pow10 ( n : CARDINAL ) : CARDINAL;

BEGIN
  RETURN powerOf10[n]
END pow10;


(* --------------------------------------------------------------------------
 * function log10(n)
 * --------------------------------------------------------------------------
 * Returns the integral part of the logarithm of 10 for argument n
 * ----------------------------------------------------------------------- *)

PROCEDURE log10 ( n : CARDINAL ) : CARDINAL;

VAR
  index, approximation : CARDINAL;
  
BEGIN
  index := shr((log2(n) + 1) * 1233, 12);
  approximation := powerOf10[index];
  IF n < approximation THEN
    RETURN index - 1
  ELSE
    RETURN approximation
  END (* IF *)
END log10;


(* --------------------------------------------------------------------------
 * function maxDecimalDigits(n)
 * --------------------------------------------------------------------------
 * Returns the number of decimal digits of the largest unsigned integer that
 * can be encoded in base-2 using n number of 8-bit octets for 1 <= n <= 16.
 * ----------------------------------------------------------------------- *)

PROCEDURE maxDecimalDigits ( octets : Card1To16 ) : CARDINAL;

BEGIN
  RETURN maxDecDigits[octets]
END maxDecimalDigits;


(* --------------------------------------------------------------------------
 * function twosComplement(n)
 * --------------------------------------------------------------------------
 * Returns the two's complement of n
 * ----------------------------------------------------------------------- *)

PROCEDURE twosComplement ( n : CARDINAL ) : CARDINAL;

BEGIN
  RETURN MAX(CARDINAL) - n + 1
END twosComplement;


(* --------------------------------------------------------------------------
 * function addWouldOverflow(n, m)
 * --------------------------------------------------------------------------
 * Returns TRUE if operation n + m overflows, else FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE addWouldOverflow ( n, m : CARDINAL ) : BOOLEAN;

BEGIN
  RETURN (m > 0) AND (n > MAX(CARDINAL) - m)
END addWouldOverflow;


(* Bit operations *)

(* --------------------------------------------------------------------------
 * function shl(n, shiftFactor)
 * --------------------------------------------------------------------------
 * Returns the value of n, shifted left by shiftFactor.
 * ----------------------------------------------------------------------- *)

PROCEDURE shl ( n, shiftFactor : CARDINAL ) : CARDINAL;

VAR
  pivotalBit : CARDINAL;

BEGIN
  (* shifting by Bitwidth and more produces all zeroes *)
  IF shiftFactor > Bitwidth-1 THEN
    RETURN 0
  END; (* IF *)
  
  (* bit at position Bitwidth - shiftFactor is pivotal *)
  pivotalBit := Bitwidth - shiftFactor;
  
  (* clear bits including and above pivotal bit to avoid overflow *)
  IF n >= powerOf2[pivotalBit] THEN
    ClearHighestNBits(n, pivotalBit)
  END; (* IF *)
  
  (* shift left safely *)
  RETURN n * powerOf2[shiftFactor]
END shl;


(* --------------------------------------------------------------------------
 * function shr(n, shiftFactor)
 * --------------------------------------------------------------------------
 * Returns the value of n, shifted right by shiftFactor.
 * ----------------------------------------------------------------------- *)

PROCEDURE shr ( n, shiftFactor : CARDINAL ) : CARDINAL;

BEGIN
  (* shifting by Bitwidth and more produces all zeroes *)
  IF shiftFactor > Bitwidth-1 THEN
    RETURN 0
  END; (* IF *)
  
  RETURN n DIV (shiftFactor + 1)
END shr;


(* --------------------------------------------------------------------------
 * function reqBits(n)
 * --------------------------------------------------------------------------
 * Returns the minimum number of bits required to represent n.
 * ----------------------------------------------------------------------- *)

PROCEDURE reqBits ( n : CARDINAL ) : CARDINAL;

VAR
  bits, weight, maxWeight : CARDINAL;

BEGIN
  bits := 7;
  weight := 128;
  maxWeight := n DIV 2 + 1;
  
  WHILE (weight < maxWeight) DO
    bits := bits + 8;
    weight := weight * 256
  END; (* WHILE *)
  
  RETURN bits + 1
END reqBits;


(* --------------------------------------------------------------------------
 * function MSB(n)
 * --------------------------------------------------------------------------
 * Returns TRUE if the most significant bit of n is set, else FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE MSB ( n : CARDINAL ) : BOOLEAN;

BEGIN
  RETURN (n >= powerOf2[Bitwidth-1])
END MSB;


(* --------------------------------------------------------------------------
 * procedure SetMSB(n)
 * --------------------------------------------------------------------------
 * Sets the most significant bit of n.
 * ----------------------------------------------------------------------- *)

PROCEDURE SetMSB ( VAR n : CARDINAL );

VAR
  k : CARDINAL;
  
BEGIN
  (* mask value *)
  k := powerOf2[Bitwidth-1];
  
  (* only if MSB is not already set *)
  IF n < k THEN
    (* adding mask sets MSB *)
    n := n + k
  END (* IF *)
END SetMSB;


(* --------------------------------------------------------------------------
 * procedure ClearMSB(n)
 * --------------------------------------------------------------------------
 * Clears the most significant bit of n.
 * ----------------------------------------------------------------------- *)

PROCEDURE ClearMSB ( VAR n : CARDINAL );

VAR
  k : CARDINAL;
  
BEGIN
  (* mask value *)
  k := powerOf2[Bitwidth-1];
  
  (* only if MSB is set *)
  IF n >= k THEN
    (* subtracting mask clears MSB *)
    n := n + k
  END (* IF *)
END ClearMSB;


(* --------------------------------------------------------------------------
 * procedure ClearHighestNBits(value, n)
 * --------------------------------------------------------------------------
 * Clears bits [MSB..MSB-n] of value.
 * ----------------------------------------------------------------------- *)

PROCEDURE ClearHighestNBits ( VAR value : CARDINAL; n : CARDINAL );

VAR
  mask : CARDINAL;
  
BEGIN
  (* no point clearing bits we don't have *)
  IF n > Bitwidth-1 THEN
    RETURN
  END; (* IF *)
  
  (* clearing from bit 0 produces all zeroes *)
  IF n = 0 THEN
    value := 0;
    RETURN
  END; (* IF *)
  
  (* shift lower bits out to the right *)
  mask := value DIV (n + 1);
  
  (* shift them back, thereby clearing the low bits, obtaining a mask *)
  mask := mask * powerOf2[n + 1];
  
  (* subtract the mask, thereby clearing the high bits *)
  value := value - mask
END ClearHighestNBits;


(* ************************************************************************ *
 * Private Operations                                                       *
 * ************************************************************************ *)

(* --------------------------------------------------------------------------
 * Data table for powers of 2
 * ----------------------------------------------------------------------- *)

VAR
  powerOf2 : ARRAY [0..Bitwidth-1] OF CARDINAL;


(* --------------------------------------------------------------------------
 * procedure InitPow2Table
 * --------------------------------------------------------------------------
 * Initialises data table with powers of 2.
 * ----------------------------------------------------------------------- *)

PROCEDURE InitPow2Table;

VAR
  index : CARDINAL;

BEGIN
  powerOf2[0] := 1;
  FOR index := 1 TO Bitwidth-1 DO
    powerOf2[index] := powerOf2[index-1] * 2
  END (* FOR *)
END InitPow2Table;


(* --------------------------------------------------------------------------
 * Data table for powers of 10
 * ----------------------------------------------------------------------- *)

VAR
  powerOf10 : ARRAY [0..DecDigits-1] OF CARDINAL;


(* --------------------------------------------------------------------------
 * procedure InitPow10Table
 * --------------------------------------------------------------------------
 * Initialises data table with powers of 10.
 * ----------------------------------------------------------------------- *)

PROCEDURE InitPow10Table;

VAR
  index : CARDINAL;

BEGIN  
  powerOf10[0] := 1;
  FOR index := 1 TO DecDigits-1 DO
    powerOf10[index] := powerOf10[index-1] * 10
  END (* FOR *)
END InitPow10Table;


(* --------------------------------------------------------------------------
 * Data table for maximum decimal digits
 * ----------------------------------------------------------------------- *)

VAR
  maxDecDigits : ARRAY [1..16] OF CARDINAL;


(* --------------------------------------------------------------------------
 * procedure: IntMaxDecDigitsTable
 * --------------------------------------------------------------------------
 * Initialises data table for maximum decimal digits.
 * ----------------------------------------------------------------------- *)

PROCEDURE IntMaxDecDigitsTable;

BEGIN
  maxDecDigits[1]  := 3;  (*   8 bits *)
  maxDecDigits[2]  := 5;  (*  16 bits *)
  maxDecDigits[3]  := 8;  (*  24 bits *)
  maxDecDigits[4]  := 10; (*  32 bits *)
  maxDecDigits[5]  := 13; (*  40 bits *)
  maxDecDigits[6]  := 15; (*  48 bits *)
  maxDecDigits[7]  := 17; (*  56 bits *)
  maxDecDigits[8]  := 20; (*  64 bits *)
  maxDecDigits[9]  := 22; (*  72 bits *)
  maxDecDigits[10] := 25; (*  80 bits *)
  maxDecDigits[11] := 27; (*  88 bits *)
  maxDecDigits[12] := 29; (*  96 bits *)
  maxDecDigits[13] := 32; (* 104 bits *)
  maxDecDigits[14] := 34; (* 112 bits *)
  maxDecDigits[15] := 37; (* 120 bits *)
  maxDecDigits[16] := 39  (* 128 bits *)
END IntMaxDecDigitsTable;


(* Initialise all data tables *)

BEGIN
  InitPow2Table;
  InitPow10Table;
  IntMaxDecDigitsTable
END CardMath.