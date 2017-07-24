(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

MODULE CheckMemModel; (* PIM version *)

(* Prints the bit widths of types CARDINAL and LONGINT to the console *)

IMPORT Terminal;
 

(* ---------------------------------------------------------------------------
 * bit width of type CARDINAL
 * ------------------------------------------------------------------------ *)

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
  
  CardBitwidth =
    8*ORD(BW8) + 16*ORD(BW16) + 24*ORD(BW24) + 32*ORD(BW32) +
    40*ORD(BW40) + 48*ORD(BW48) + 56*ORD(BW56) + 64*ORD(BW64) +
    72*ORD(BW72) + 80*ORD(BW80) + 88*ORD(BW88) + 96*ORD(BW96) +
    104*ORD(BW104) + 112*ORD(BW112) + 120*ORD(BW120) + 128*ORD(BW128);


(* ---------------------------------------------------------------------------
 * bit width of type LONGINT
 * ------------------------------------------------------------------------ *)

CONST
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
  
  LBW8 = (MAX(LONGINT) <= 127);
  LBW16 = (MaxLongIntDivPow2Of8 > 0) AND (MaxLongIntDivPow2Of8 <= 127);
  LBW24 = (MaxLongIntDivPow2Of16 > 0) AND (MaxLongIntDivPow2Of16 <= 127);
  LBW32 = (MaxLongIntDivPow2Of24 > 0) AND (MaxLongIntDivPow2Of24 <= 127);
  LBW40 = (MaxLongIntDivPow2Of32 > 0) AND (MaxLongIntDivPow2Of32 <= 127);
  LBW48 = (MaxLongIntDivPow2Of40 > 0) AND (MaxLongIntDivPow2Of40 <= 127);
  LBW56 = (MaxLongIntDivPow2Of48 > 0) AND (MaxLongIntDivPow2Of48 <= 127);
  LBW64 = (MaxLongIntDivPow2Of56 > 0) AND (MaxLongIntDivPow2Of56 <= 127);
  LBW72  = (MaxLongIntDivPow2Of64 > 0) AND (MaxLongIntDivPow2Of64 <= 127);
  LBW80  = (MaxLongIntDivPow2Of72 > 0) AND (MaxLongIntDivPow2Of72 <= 127);
  LBW88  = (MaxLongIntDivPow2Of80 > 0) AND (MaxLongIntDivPow2Of80 <= 127);
  LBW96  = (MaxLongIntDivPow2Of88 > 0) AND (MaxLongIntDivPow2Of88 <= 127);
  LBW104 = (MaxLongIntDivPow2Of96 > 0) AND (MaxLongIntDivPow2Of96 <= 127);
  LBW112 = (MaxLongIntDivPow2Of104 > 0) AND (MaxLongIntDivPow2Of104 <= 127);
  LBW120 = (MaxLongIntDivPow2Of112 > 0) AND (MaxLongIntDivPow2Of112 <= 127);
  LBW128 = (MaxLongIntDivPow2Of120 > 0) AND (MaxLongIntDivPow2Of120 <= 127);
  
  LongIntBitwidth =
    8*ORD(LBW8) + 16*ORD(LBW16) + 24*ORD(LBW24) + 32*ORD(LBW32) +
    40*ORD(LBW40) + 48*ORD(LBW48) + 56*ORD(LBW56) + 64*ORD(LBW64) +
    72*ORD(LBW72) + 80*ORD(LBW80) + 88*ORD(LBW88) + 96*ORD(LBW96) +
    104*ORD(LBW104) + 112*ORD(LBW112) + 120*ORD(LBW120) + 128*ORD(LBW128);

  
(* ---------------------------------------------------------------------------
 * procedure WriteNumber -- write a cardinal value to the console
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteNumber ( value : CARDINAL );

VAR
  weight, digit : CARDINAL;
  
BEGIN
  (* find highest digit *)
  weight := 1;
  WHILE value DIV weight > 10 DO
    weight := weight * 10
  END; (* WHILE *)
  
  (* print digits *)
  WHILE weight > 0 DO
    digit := value DIV weight;
    Terminal.Write(CHR(digit + 48));
    value := value MOD weight;
    weight := weight DIV 10
  END (* WHILE *)
END WriteNumber;


BEGIN (* CheckMemModel *)
  Terminal.WriteString("CARDINAL bit width: ");
  WriteNumber(CardBitwidth);
  Terminal.WriteLn;

  Terminal.WriteString("LONGINT bit width: ");
  WriteNumber(LongIntBitwidth);
  Terminal.WriteLn
END CheckMemModel.