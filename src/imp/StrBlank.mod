(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE StrBlank;

(* String Blanks used internally by Module String *)


(* ---------------------------------------------------------------------------
 * function allocSizeForStrLen(strlen)
 * ---------------------------------------------------------------------------
 * Returns the allocation size for a blank of length strlen as follows:
 * 
 * case | strlen       | offset | size      | blank type
 * -----+--------------+--------+-----------+-----------
 *  (0) |    0 ..   79 |     +1 |  strlen+1 | AOC0-AOC79
 * -----+--------------+--------+-----------+-----------
 *  (1) |   80 ..   87 |     +8 |        88 |      AOC87
 *  (2) |   88 ..   95 |     +8 |        96 |      AOC95
 * -----+--------------+--------+-----------+-----------
 *  (3) |   96 ..  111 |    +16 |       112 |     AOC111
 *  (4) |  112 ..  127 |    +16 |       128 |     AOC127
 * -----+--------------+--------+-----------+-----------
 *  (5) |  128 ..  191 |    +64 |       192 |     AOC191
 *  (6) |  192 ..  255 |    +64 |       256 |     AOC255
 * -----+--------------+--------+-----------+-----------
 *  (7) |  256 ..  511 |   +256 |       512 |     AOC511
 *  (8) |  512 ..  767 |   +256 |       768 |     AOC767
 *  (9) |  768 .. 1023 |   +256 |      1024 |    AOC1023
 * (10) | 1024 .. 1279 |   +256 |      1280 |    AOC1279
 * (11) | 1280 .. 1535 |   +256 |      1536 |    AOC1535
 * (12) | 1536 .. 1791 |   +256 |      1792 |    AOC1791
 * (13) | 1792 .. 2047 |   +256 |      2048 |    AOC2047
 * -----+--------------+--------+-----------+-----------
 * (14) | 2048 .. 2559 |   +512 |      2560 |    AOC2559
 * (15) | 2560 .. 3071 |   +512 |      3072 |    AOC3071
 * -----+--------------+--------+-----------+-----------
 * (16) |      >= 3072 |  +1024 | MaxLength |    Largest
 * ------------------------------------------------------------------------ *)

PROCEDURE allocSizeForStrLen ( strlen : CARDINAL ) : CARDINAL;

VAR
  size : CARDINAL;
  
BEGIN
  IF strlen < 80 THEN
    (* case 0 *) size := strlen + 1
  ELSE
    IF strlen < 768 THEN
      IF strlen < 128 THEN
        IF strlen < 96 THEN
          IF strlen < 88 THEN
            (* case 1 *) size := 88
          ELSE (* strlen >= 88 *)
            (* case 2 *) size := 96
          END (* IF *)
        ELSE (* strlen >= 96 *)
          IF strlen < 112 THEN
            (* case 3 *) size := 112
          ELSE (* strlen >= 112 *)
            (* case 4 *) size := 128
          END (* IF *)
        END (* IF *)
      ELSE (* strlen >= 128 *)
        IF strlen < 256 THEN
          IF strlen < 192 THEN
            (* case 5 *) size := 192
          ELSE (* strlen >= 192 *)
            (* case 6 *) size := 256
          END (* IF *)
        ELSE (* strlen >= 256 *)
          IF strlen < 512 THEN
            (* case 7 *) size := 512
          ELSE (* strlen >= 512 *)
            (* case 8 *) size := 768
          END (* IF *)
        END (* IF *)
      END (* IF *)
    ELSE (* strlen >= 768 *)
      IF strlen < 1792 THEN
        IF strlen < 1280 THEN
          IF strlen < 1024 THEN
            (* case 9 *) size := 1024
          ELSE (* strlen >= 1024 *)
            (* case 10 *) size := 1280
          END (* IF *)
        ELSE (* strlen >= 1280 *)
          IF strlen < 1536 THEN
            (* case 11 *) size := 1536
          ELSE (* strlen >= 1536 *)
            (* case 12 *) size := 1792
          END (* IF *)
        END (* IF *)
      ELSE (* strlen >= 1792 *)
        IF strlen < 2560 THEN
          IF strlen < 2048 THEN
            (* case 13 *) size := 2048
          ELSE (* strlen >= 2048 *)
            (* case 14 *) size := 2560
          END (* IF *)
        ELSE (* strlen >= 2560 *)
          IF strlen < 3072 THEN
            (* case 15 *) size := 3072
          ELSE (* strlen >= 3072 *)
            (* case 16 *) size := MaxLength + 1
          END (* IF *)
        END (* IF *)
      END (* IF *)
    END (* IF *)
  END; (* IF *)
  
  RETURN size
END allocSizeForStrLen;


END StrBlank.