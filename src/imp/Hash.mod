(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation. *)

IMPLEMENTATION MODULE Hash;

(* General Purpose Hash Function *)

IMPORT Size; (* Base Type *)

FROM Size IMPORT SizeT; (* alias for Size.Size *)


(* ---------------------------------------------------------------------------
 * assert that MaxBits is in range [16..128]
 * ------------------------------------------------------------------------ *)

CONST (* causes compile time error if assert condition is not met *)
  MaxBitsValueLowerBoundAssert = 1 DIV ORD(MaxBits>=16);
  MaxBitsValueUpperBoundAssert = 1 DIV ORD(MaxBits<=128);
  

(* ---------------------------------------------------------------------------
 * number of bits available for use
 * ------------------------------------------------------------------------ *)

CONST
  AddressableBits = Size.AddressableBits;
  

(* ---------------------------------------------------------------------------
 * number of bits to be used by key type
 * ------------------------------------------------------------------------ *)

CONST
  BitsInUse =
    ORD(AddressableBits > MaxBits) * MaxBits +
    ORD(AddressableBits <= MaxBits) * AddressableBits;
  

(* ---------------------------------------------------------------------------
 * intermediary constants
 * ------------------------------------------------------------------------ *)

CONST
  TTP16  = ORD(AddressableBits>16) * 65535 + 1;
  TTP32  = ORD(AddressableBits>32) * TTP16 * TTP16;
  TTP48  = ORD(AddressableBits>48) * TTP32 * TTP16;
  TTP64  = ORD(AddressableBits>64) * TTP48 * TTP16;
  TTP80  = ORD(AddressableBits>80) * TTP64 * TTP16;
  TTP96  = ORD(AddressableBits>96) * TTP80 * TTP16;
  TTP112 = ORD(AddressableBits>112) * TTP96 * TTP16;


(* ---------------------------------------------------------------------------
 * maximum value for key type
 * ------------------------------------------------------------------------ *)
  
CONST
  MaxKey =
    VAL(SizeT,
      ORD(BitsInUse>0) * 1 +
      ORD(BitsInUse>1) * 2 +
      ORD(BitsInUse>2) * 4 +
      ORD(BitsInUse>3) * 8 +
      ORD(BitsInUse>4) * 16 +
      ORD(BitsInUse>5) * 32 +
      ORD(BitsInUse>6) * 64 +
      ORD(BitsInUse>7) * 128 +
      ORD(BitsInUse>8) * 256 +
      ORD(BitsInUse>9) * 512 +
      ORD(BitsInUse>10) * 1024 +
      ORD(BitsInUse>11) * 2048 +
      ORD(BitsInUse>12) * 4096 +
      ORD(BitsInUse>13) * 8192 +
      ORD(BitsInUse>14) * 16384 +
      ORD(BitsInUse>15) * 32768 +
      ORD(BitsInUse>16) * TTP16 +
      ORD(BitsInUse>17) * TTP16 * 2 +
      ORD(BitsInUse>18) * TTP16 * 4 +
      ORD(BitsInUse>19) * TTP16 * 8 +
      ORD(BitsInUse>20) * TTP16 * 16 +
      ORD(BitsInUse>21) * TTP16 * 32 +
      ORD(BitsInUse>22) * TTP16 * 64 +
      ORD(BitsInUse>23) * TTP16 * 128 +
      ORD(BitsInUse>24) * TTP16 * 256 +
      ORD(BitsInUse>25) * TTP16 * 512 +
      ORD(BitsInUse>26) * TTP16 * 1024 +
      ORD(BitsInUse>27) * TTP16 * 2048 +
      ORD(BitsInUse>28) * TTP16 * 4096 +
      ORD(BitsInUse>29) * TTP16 * 8192 +
      ORD(BitsInUse>30) * TTP16 * 16384 +
      ORD(BitsInUse>31) * TTP16 * 32768 +
      ORD(BitsInUse>32) * TTP32 +
      ORD(BitsInUse>33) * TTP32 * 2 +
      ORD(BitsInUse>34) * TTP32 * 4 +
      ORD(BitsInUse>35) * TTP32 * 8 +
      ORD(BitsInUse>36) * TTP32 * 16 +
      ORD(BitsInUse>37) * TTP32 * 32 +
      ORD(BitsInUse>38) * TTP32 * 64 +
      ORD(BitsInUse>39) * TTP32 * 128 +
      ORD(BitsInUse>40) * TTP32 * 256 +
      ORD(BitsInUse>41) * TTP32 * 512 +
      ORD(BitsInUse>42) * TTP32 * 1024 +
      ORD(BitsInUse>43) * TTP32 * 2048 +
      ORD(BitsInUse>44) * TTP32 * 4096 +
      ORD(BitsInUse>45) * TTP32 * 8192 +
      ORD(BitsInUse>46) * TTP32 * 16384 +
      ORD(BitsInUse>47) * TTP32 * 32768 +
      ORD(BitsInUse>48) * TTP48 +
      ORD(BitsInUse>49) * TTP48 * 2 +
      ORD(BitsInUse>50) * TTP48 * 4 +
      ORD(BitsInUse>51) * TTP48 * 8 +
      ORD(BitsInUse>52) * TTP48 * 16 +
      ORD(BitsInUse>53) * TTP48 * 32 +
      ORD(BitsInUse>54) * TTP48 * 64 +
      ORD(BitsInUse>55) * TTP48 * 128 +
      ORD(BitsInUse>56) * TTP48 * 256 +
      ORD(BitsInUse>57) * TTP48 * 512 +
      ORD(BitsInUse>58) * TTP48 * 1024 +
      ORD(BitsInUse>59) * TTP48 * 2048 +
      ORD(BitsInUse>60) * TTP48 * 4096 +
      ORD(BitsInUse>61) * TTP48 * 8192 +
      ORD(BitsInUse>62) * TTP48 * 16384 +
      ORD(BitsInUse>63) * TTP48 * 32768 +
      ORD(BitsInUse>64) * TTP64 +
      ORD(BitsInUse>65) * TTP64 * 2 +
      ORD(BitsInUse>66) * TTP64 * 4 +
      ORD(BitsInUse>67) * TTP64 * 8 +
      ORD(BitsInUse>68) * TTP64 * 16 +
      ORD(BitsInUse>69) * TTP64 * 32 +
      ORD(BitsInUse>70) * TTP64 * 64 +
      ORD(BitsInUse>71) * TTP64 * 128 +
      ORD(BitsInUse>72) * TTP64 * 256 +
      ORD(BitsInUse>73) * TTP64 * 512 +
      ORD(BitsInUse>74) * TTP64 * 1024 +
      ORD(BitsInUse>75) * TTP64 * 2048 +
      ORD(BitsInUse>76) * TTP64 * 4096 +
      ORD(BitsInUse>77) * TTP64 * 8192 +
      ORD(BitsInUse>78) * TTP64 * 16384 +
      ORD(BitsInUse>79) * TTP64 * 32768 +
      ORD(BitsInUse>80) * TTP80 +
      ORD(BitsInUse>81) * TTP80 * 2 +
      ORD(BitsInUse>82) * TTP80 * 4 +
      ORD(BitsInUse>83) * TTP80 * 8 +
      ORD(BitsInUse>84) * TTP80 * 16 +
      ORD(BitsInUse>85) * TTP80 * 32 +
      ORD(BitsInUse>86) * TTP80 * 64 +
      ORD(BitsInUse>87) * TTP80 * 128 +
      ORD(BitsInUse>88) * TTP80 * 256 +
      ORD(BitsInUse>89) * TTP80 * 512 +
      ORD(BitsInUse>90) * TTP80 * 1024 +
      ORD(BitsInUse>91) * TTP80 * 2048 +
      ORD(BitsInUse>92) * TTP80 * 4096 +
      ORD(BitsInUse>93) * TTP80 * 8192 +
      ORD(BitsInUse>94) * TTP80 * 16384 +
      ORD(BitsInUse>95) * TTP80 * 32768 +
      ORD(BitsInUse>96) * TTP96 +
      ORD(BitsInUse>97) * TTP96 * 2 +
      ORD(BitsInUse>98) * TTP96 * 4 +
      ORD(BitsInUse>99) * TTP96 * 8 +
      ORD(BitsInUse>100) * TTP96 * 16 +
      ORD(BitsInUse>101) * TTP96 * 32 +
      ORD(BitsInUse>102) * TTP96 * 64 +
      ORD(BitsInUse>103) * TTP96 * 128 +
      ORD(BitsInUse>104) * TTP96 * 256 +
      ORD(BitsInUse>105) * TTP96 * 512 +
      ORD(BitsInUse>106) * TTP96 * 1024 +
      ORD(BitsInUse>107) * TTP96 * 2048 +
      ORD(BitsInUse>108) * TTP96 * 4096 +
      ORD(BitsInUse>109) * TTP96 * 8192 +
      ORD(BitsInUse>110) * TTP96 * 16384 +
      ORD(BitsInUse>111) * TTP96 * 32768 +
      ORD(BitsInUse>112) * TTP112 +
      ORD(BitsInUse>113) * TTP112 * 2 +
      ORD(BitsInUse>114) * TTP112 * 4 +
      ORD(BitsInUse>115) * TTP112 * 8 +
      ORD(BitsInUse>116) * TTP112 * 16 +
      ORD(BitsInUse>117) * TTP112 * 32 +
      ORD(BitsInUse>118) * TTP112 * 64 +
      ORD(BitsInUse>119) * TTP112 * 128 +
      ORD(BitsInUse>120) * TTP112 * 256 +
      ORD(BitsInUse>121) * TTP112 * 512 +
      ORD(BitsInUse>122) * TTP112 * 1024 +
      ORD(BitsInUse>123) * TTP112 * 2048 +
      ORD(BitsInUse>124) * TTP112 * 4096 +
      ORD(BitsInUse>125) * TTP112 * 8192 +
      ORD(BitsInUse>126) * TTP112 * 16384 +
      ORD(BitsInUse>127) * TTP112 * 32768);


(* ---------------------------------------------------------------------------
 * key type
 * ------------------------------------------------------------------------ *)

TYPE Key = SizeT [0..MaxKey];


(* ---------------------------------------------------------------------------
 * index type for bit addressing
 * ------------------------------------------------------------------------ *)

TYPE BitIndex = SizeT [0..AddressableBits-1];


(* ---------------------------------------------------------------------------
 * weight of MSB of key type = pow2(BitsInUse-1)
 * ------------------------------------------------------------------------ *)

CONST
  KeyMSBWeight =
    VAL(Key,
      ORD(BitsInUse=1) * 1 +
      ORD(BitsInUse=2) * 2 +
      ORD(BitsInUse=3) * 4 +
      ORD(BitsInUse=4) * 8 +
      ORD(BitsInUse=5) * 16 +
      ORD(BitsInUse=6) * 32 +
      ORD(BitsInUse=7) * 64 +
      ORD(BitsInUse=8) * 128 +
      ORD(BitsInUse=9) * 256 +
      ORD(BitsInUse=10) * 512 +
      ORD(BitsInUse=11) * 1024 +
      ORD(BitsInUse=12) * 2048 +
      ORD(BitsInUse=13) * 4096 +
      ORD(BitsInUse=14) * 8192 +
      ORD(BitsInUse=15) * 16384 +
      ORD(BitsInUse=16) * 32768 +
      ORD(BitsInUse=17) * TTP16 +
      ORD(BitsInUse=18) * TTP16 * 2 +
      ORD(BitsInUse=19) * TTP16 * 4 +
      ORD(BitsInUse=20) * TTP16 * 8 +
      ORD(BitsInUse=21) * TTP16 * 16 +
      ORD(BitsInUse=22) * TTP16 * 32 +
      ORD(BitsInUse=23) * TTP16 * 64 +
      ORD(BitsInUse=24) * TTP16 * 128 +
      ORD(BitsInUse=25) * TTP16 * 256 +
      ORD(BitsInUse=26) * TTP16 * 512 +
      ORD(BitsInUse=27) * TTP16 * 1024 +
      ORD(BitsInUse=28) * TTP16 * 2048 +
      ORD(BitsInUse=29) * TTP16 * 4096 +
      ORD(BitsInUse=30) * TTP16 * 8192 +
      ORD(BitsInUse=31) * TTP16 * 16384 +
      ORD(BitsInUse=32) * TTP16 * 32768 +
      ORD(BitsInUse=33) * TTP32 +
      ORD(BitsInUse=34) * TTP32 * 2 +
      ORD(BitsInUse=35) * TTP32 * 4 +
      ORD(BitsInUse=36) * TTP32 * 8 +
      ORD(BitsInUse=37) * TTP32 * 16 +
      ORD(BitsInUse=38) * TTP32 * 32 +
      ORD(BitsInUse=39) * TTP32 * 64 +
      ORD(BitsInUse=40) * TTP32 * 128 +
      ORD(BitsInUse=41) * TTP32 * 256 +
      ORD(BitsInUse=42) * TTP32 * 512 +
      ORD(BitsInUse=43) * TTP32 * 1024 +
      ORD(BitsInUse=44) * TTP32 * 2048 +
      ORD(BitsInUse=45) * TTP32 * 4096 +
      ORD(BitsInUse=46) * TTP32 * 8192 +
      ORD(BitsInUse=47) * TTP32 * 16384 +
      ORD(BitsInUse=48) * TTP32 * 32768 +
      ORD(BitsInUse=49) * TTP48 +
      ORD(BitsInUse=50) * TTP48 * 2 +
      ORD(BitsInUse=51) * TTP48 * 4 +
      ORD(BitsInUse=52) * TTP48 * 8 +
      ORD(BitsInUse=53) * TTP48 * 16 +
      ORD(BitsInUse=54) * TTP48 * 32 +
      ORD(BitsInUse=55) * TTP48 * 64 +
      ORD(BitsInUse=56) * TTP48 * 128 +
      ORD(BitsInUse=57) * TTP48 * 256 +
      ORD(BitsInUse=58) * TTP48 * 512 +
      ORD(BitsInUse=59) * TTP48 * 1024 +
      ORD(BitsInUse=60) * TTP48 * 2048 +
      ORD(BitsInUse=61) * TTP48 * 4096 +
      ORD(BitsInUse=62) * TTP48 * 8192 +
      ORD(BitsInUse=63) * TTP48 * 16384 +
      ORD(BitsInUse=64) * TTP48 * 32768 +
      ORD(BitsInUse=65) * TTP64 +
      ORD(BitsInUse=66) * TTP64 * 2 +
      ORD(BitsInUse=67) * TTP64 * 4 +
      ORD(BitsInUse=68) * TTP64 * 8 +
      ORD(BitsInUse=69) * TTP64 * 16 +
      ORD(BitsInUse=70) * TTP64 * 32 +
      ORD(BitsInUse=71) * TTP64 * 64 +
      ORD(BitsInUse=72) * TTP64 * 128 +
      ORD(BitsInUse=73) * TTP64 * 256 +
      ORD(BitsInUse=74) * TTP64 * 512 +
      ORD(BitsInUse=75) * TTP64 * 1024 +
      ORD(BitsInUse=76) * TTP64 * 2048 +
      ORD(BitsInUse=77) * TTP64 * 4096 +
      ORD(BitsInUse=78) * TTP64 * 8192 +
      ORD(BitsInUse=79) * TTP64 * 16384 +
      ORD(BitsInUse=80) * TTP64 * 32768 +
      ORD(BitsInUse=81) * TTP80 +
      ORD(BitsInUse=82) * TTP80 * 2 +
      ORD(BitsInUse=83) * TTP80 * 4 +
      ORD(BitsInUse=84) * TTP80 * 8 +
      ORD(BitsInUse=85) * TTP80 * 16 +
      ORD(BitsInUse=86) * TTP80 * 32 +
      ORD(BitsInUse=87) * TTP80 * 64 +
      ORD(BitsInUse=88) * TTP80 * 128 +
      ORD(BitsInUse=89) * TTP80 * 256 +
      ORD(BitsInUse=90) * TTP80 * 512 +
      ORD(BitsInUse=91) * TTP80 * 1024 +
      ORD(BitsInUse=92) * TTP80 * 2048 +
      ORD(BitsInUse=93) * TTP80 * 4096 +
      ORD(BitsInUse=94) * TTP80 * 8192 +
      ORD(BitsInUse=95) * TTP80 * 16384 +
      ORD(BitsInUse=96) * TTP80 * 32768 +
      ORD(BitsInUse=97) * TTP96 +
      ORD(BitsInUse=98) * TTP96 * 2 +
      ORD(BitsInUse=99) * TTP96 * 4 +
      ORD(BitsInUse=100) * TTP96 * 8 +
      ORD(BitsInUse=101) * TTP96 * 16 +
      ORD(BitsInUse=102) * TTP96 * 32 +
      ORD(BitsInUse=103) * TTP96 * 64 +
      ORD(BitsInUse=104) * TTP96 * 128 +
      ORD(BitsInUse=105) * TTP96 * 256 +
      ORD(BitsInUse=106) * TTP96 * 512 +
      ORD(BitsInUse=107) * TTP96 * 1024 +
      ORD(BitsInUse=108) * TTP96 * 2048 +
      ORD(BitsInUse=109) * TTP96 * 4096 +
      ORD(BitsInUse=110) * TTP96 * 8192 +
      ORD(BitsInUse=111) * TTP96 * 16384 +
      ORD(BitsInUse=112) * TTP96 * 32768 +
      ORD(BitsInUse=113) * TTP112 +
      ORD(BitsInUse=114) * TTP112 * 2 +
      ORD(BitsInUse=115) * TTP112 * 4 +
      ORD(BitsInUse=116) * TTP112 * 8 +
      ORD(BitsInUse=117) * TTP112 * 16 +
      ORD(BitsInUse=118) * TTP112 * 32 +
      ORD(BitsInUse=119) * TTP112 * 64 +
      ORD(BitsInUse=120) * TTP112 * 128 +
      ORD(BitsInUse=121) * TTP112 * 256 +
      ORD(BitsInUse=122) * TTP112 * 512 +
      ORD(BitsInUse=123) * TTP112 * 1024 +
      ORD(BitsInUse=124) * TTP112 * 2048 +
      ORD(BitsInUse=125) * TTP112 * 4096 +
      ORD(BitsInUse=126) * TTP112 * 8192 +
      ORD(BitsInUse=127) * TTP112 * 16384 +
      ORD(BitsInUse=128) * TTP112 * 32768);


(* ---------------------------------------------------------------------------
 * shift factors of hash function
 * ---------------------------------------------------------------------------
 * For Keys > 16 bits, use A = 6 and B = 16,
 * For Keys <= 16 bits, use A = 3 and B = 8. (experimental)
 * ------------------------------------------------------------------------ *)

  A = ORD(BitsInUse<=16) * 3 + ORD(BitsInUse>16) * 6;
  B = ORD(BitsInUse<=16) * 8 + ORD(BitsInUse>16) * 16;


(* ---------------------------------------------------------------------------
 * function Hash.initialValue()
 * ------------------------------------------------------------------------ *)

PROCEDURE initialValue () : Key;

BEGIN
  RETURN 0
END initialValue;


(* ---------------------------------------------------------------------------
 * function:  Hash.valueForNextChar( hash, ch )
 * ------------------------------------------------------------------------ *)

PROCEDURE valueForNextChar ( hash : Key; ch : CHAR ) : Key;

BEGIN
  RETURN VAL(Key, ch) + SHL(hash, A) + SHL(hash, B) - hash
END valueForNextChar;


(* ---------------------------------------------------------------------------
 * function:  Hash.finalValue( hash )
 * ------------------------------------------------------------------------ *)

PROCEDURE finalValue ( hash : Key ) : Key;

BEGIN
  (* Clear MSB of hash value *)
  IF hash >= KeyMSBWeight THEN
    hash := hash - KeyMSBWeight
  END; (* IF *)
  
  RETURN hash
END finalValue;


(* ---------------------------------------------------------------------------
 * function:  Hash.valueForArray( array )
 * ------------------------------------------------------------------------ *)

CONST NUL = CHR(0);

PROCEDURE valueForArray ( VAR (*CONST*) array : ARRAY OF CHAR ) : Key;
  
VAR
  ch : CHAR;
  hash : Key;
  index : CARDINAL; (* char index *)
  
BEGIN
  index := 0;
  hash := initialValue();
  
  ch := array[index];
  WHILE (ch # NUL) AND (index < HIGH(array)) DO
    hash := VAL(Key, ch) + SHL(hash, A) + SHL(hash, B) - hash;
    index := index + 1;
    ch := array[index]
  END; (* WHILE *)
  
  (* Clear MSB of hash value *)
  IF hash >= KeyMSBWeight THEN
    hash := hash - KeyMSBWeight
  END; (* IF *)
  
  RETURN hash
END valueForArray;


(* ---------------------------------------------------------------------------
 * function Hash.valueForArraySlice( array, start, end )
 * ---------------------------------------------------------------------------
 * Returns the final hash value for the given character array slice.
 * ------------------------------------------------------------------------ *)

PROCEDURE valueForArraySlice
  ( VAR (*CONST*) array : ARRAY OF CHAR; start, end : CARDINAL ) : Key;

VAR
  ch : CHAR;
  hash : Key;
  index : CARDINAL; (* char index *)
  
BEGIN
  IF (start > end) OR (end > HIGH(array)) THEN
    RETURN 0
  END; (* IF *)
  
  index := start;
  hash := initialValue();
  
  ch := array[index];
  WHILE (ch # NUL) AND (index <= end) DO
    hash := ORD(ch) + SHL(hash, A) + SHL(hash, B) - hash;
    index := index + 1;
    ch := array[index]
  END; (* WHILE *)
  
  (* Clear MSB of hash value *)
  IF hash >= KeyMSBWeight THEN
    hash := hash - KeyMSBWeight
  END; (* IF *)
  
  RETURN hash
END valueForArraySlice;


(* ---------------------------------------------------------------------------
 * function Hash.mod( hash, n )
 * ---------------------------------------------------------------------------
 * Returns the CARDINAL value of hash MOD n for n IN [1..MAX(CARDINAL)].
 * ------------------------------------------------------------------------ *)

PROCEDURE mod ( hash : Key; n : NatCard ) : CARDINAL;

BEGIN
  RETURN VAL(CARDINAL, VAL(SizeT, hash) MOD VAL(SizeT, n))
END mod;


(* ************************************************************************ *
 * Private Operations                                                       *
 * ************************************************************************ *)

(* ---------------------------------------------------------------------------
 * function: shl( hash, shiftFactor )
 * ---------------------------------------------------------------------------
 * Returns the value of hash shifted left by shiftFactor. Ensures no overflow.
 * ------------------------------------------------------------------------ *)

PROCEDURE SHL ( hash : Key; shiftFactor : BitIndex ) : Key;

VAR
  pivotalBit : BitIndex;
  
BEGIN
  (* shifting by BitsInUse and more produces all zeroes *)
  IF shiftFactor > BitsInUse-1 THEN
    RETURN 0
  END; (* IF *)
  
  (* bit at position AddressableBits-shiftFactor is pivotal *)
  pivotalBit := AddressableBits - shiftFactor;
  
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
  mask : SizeT;
  bitToClear : BitIndex;
  
BEGIN
  (* shift lower bits out to the right *)
  mask := hash DIV VAL(SizeT, lowestBitToClear+1);
  
  (* shift them back, thereby clearing the low bits *)
  mask := mask * pow2[lowestBitToClear+1];
  
  (* subtract the mask, thereby clearing the high bits *)
  hash := hash - mask
END ClearBitsInclAndAbove;


(* ---------------------------------------------------------------------------
 * array pow2[]
 * ---------------------------------------------------------------------------
 * Pre-calculated powers of 2 for n in [0..AddressableBits-1]
 * ------------------------------------------------------------------------ *)

VAR
  pow2 : ARRAY [0..MAX(BitIndex)] OF SizeT;


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
  InitPow2Table
END Hash.