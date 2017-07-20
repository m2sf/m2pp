(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

MODULE CheckMemModel; (* PIM version *)

(* Prints the bit widths of types CARDINAL and LONGINT to the console *)

IMPORT Terminal;
 

(* ---------------------------------------------------------------------------
 * bit width of type CARDINAL
 * ------------------------------------------------------------------------ *)

CONST
  CardBitwidth =
    8*ORD(BW8) + 16*ORD(BW16) + 24*ORD(BW24) + 32*ORD(BW32) +
    40*ORD(BW40) + 48*ORD(BW48) + 56*ORD(BW56) + 64*ORD(BW64);

  BW8 = MAX(CARDINAL) <= 255;
  BW16 = NOT BW8 AND (MaxCardDivPow2Of8 <= 255);
  BW24 = NOT BW16 AND (MaxCardDivPow2Of16 <= 255);
  BW32 = NOT BW24 AND (MaxCardDivPow2Of24 <= 255);
  BW40 = NOT BW32 AND (MaxCardDivPow2Of32 <= 255);
  BW48 = NOT BW40 AND (MaxCardDivPow2Of40 <= 255);
  BW56 = NOT BW48 AND (MaxCardDivPow2Of48 <= 255);
  BW64 = NOT BW56 AND (MaxCardDivPow2Of56 <= 255);

  MaxCardDivPow2Of8 = MAX(CARDINAL) DIV 256;
  MaxCardDivPow2Of16 = MaxCardDivPow2Of8 DIV 256;
  MaxCardDivPow2Of24 = MaxCardDivPow2Of16 DIV 256;
  MaxCardDivPow2Of32 = MaxCardDivPow2Of24 DIV 256;
  MaxCardDivPow2Of40 = MaxCardDivPow2Of32 DIV 256;
  MaxCardDivPow2Of48 = MaxCardDivPow2Of40 DIV 256;
  MaxCardDivPow2Of56 = MaxCardDivPow2Of48 DIV 256;
  MaxCardDivPow2Of64 = MaxCardDivPow2Of56 DIV 256;


(* ---------------------------------------------------------------------------
 * bit width of type LONGINT
 * ------------------------------------------------------------------------ *)

CONST
  LongIntBitwidth =
    8*ORD(LBW8) + 16*ORD(LBW16) + 24*ORD(LBW24) + 32*ORD(LBW32) +
    40*ORD(LBW40) + 48*ORD(LBW48) + 56*ORD(LBW56) + 64*ORD(LBW64);

  MaxLongIntDivPow2Of8 = MAX(LONGINT) DIV 256;
  MaxLongIntDivPow2Of16 = MaxLongIntDivPow2Of8 DIV 256;
  MaxLongIntDivPow2Of24 = MaxLongIntDivPow2Of16 DIV 256;
  MaxLongIntDivPow2Of32 = MaxLongIntDivPow2Of24 DIV 256;
  MaxLongIntDivPow2Of40 = MaxLongIntDivPow2Of32 DIV 256;
  MaxLongIntDivPow2Of48 = MaxLongIntDivPow2Of40 DIV 256;
  MaxLongIntDivPow2Of56 = MaxLongIntDivPow2Of48 DIV 256;
  MaxLongIntDivPow2Of64 = MaxLongIntDivPow2Of56 DIV 256;
    
  LBW8 = MAX(LONGINT) <= 127;
  LBW16 = NOT LBW8 AND (MaxLongIntDivPow2Of8 <= 127);
  LBW24 = NOT LBW16 AND (MaxLongIntDivPow2Of16 <= 127);
  LBW32 = NOT LBW24 AND (MaxLongIntDivPow2Of24 <= 127);
  LBW40 = NOT LBW32 AND (MaxLongIntDivPow2Of32 <= 127);
  LBW48 = NOT LBW40 AND (MaxLongIntDivPow2Of40 <= 127);
  LBW56 = NOT LBW48 AND (MaxLongIntDivPow2Of48 <= 127);
  LBW64 = NOT LBW56 AND (MaxLongIntDivPow2Of56 <= 127);

  
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