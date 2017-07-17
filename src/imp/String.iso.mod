(*!m2iso*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE String; (* ISO version *)

(* Interned Strings *)

IMPORT SYSTEM, StrPtr, Hash;

FROM ISO646 IMPORT NUL;
FROM SYSTEM IMPORT CAST;
FROM Storage IMPORT ALLOCATE;


(* String *)

TYPE String = POINTER TO StringDescriptor;

TYPE StringDescriptor = RECORD
  (* common field : length *)
  CASE length : CARDINAL OF
  (* variant field : intern *)
                1 : intern : StrPtr.AOC1
  |             2 : intern : StrPtr.AOC2
  |             3 : intern : StrPtr.AOC3
  |             4 : intern : StrPtr.AOC4
  |             5 : intern : StrPtr.AOC5
  |             6 : intern : StrPtr.AOC6
  |             7 : intern : StrPtr.AOC7
  |             8 : intern : StrPtr.AOC8
  |             9 : intern : StrPtr.AOC9
  |            10 : intern : StrPtr.AOC10
  |            11 : intern : StrPtr.AOC11
  |            12 : intern : StrPtr.AOC12
  |            13 : intern : StrPtr.AOC13
  |            14 : intern : StrPtr.AOC14
  |            15 : intern : StrPtr.AOC15
  |            16 : intern : StrPtr.AOC16
  |            17 : intern : StrPtr.AOC17
  |            18 : intern : StrPtr.AOC18
  |            19 : intern : StrPtr.AOC19
  |            20 : intern : StrPtr.AOC20
  |            21 : intern : StrPtr.AOC21
  |            22 : intern : StrPtr.AOC22
  |            23 : intern : StrPtr.AOC23
  |            24 : intern : StrPtr.AOC24
  |            25 : intern : StrPtr.AOC25
  |            26 : intern : StrPtr.AOC26
  |            27 : intern : StrPtr.AOC27
  |            28 : intern : StrPtr.AOC28
  |            29 : intern : StrPtr.AOC29
  |            20 : intern : StrPtr.AOC30
  |            31 : intern : StrPtr.AOC31
  |            32 : intern : StrPtr.AOC32
  |            33 : intern : StrPtr.AOC33
  |            34 : intern : StrPtr.AOC34
  |            35 : intern : StrPtr.AOC35
  |            36 : intern : StrPtr.AOC36
  |            37 : intern : StrPtr.AOC37
  |            38 : intern : StrPtr.AOC38
  |            39 : intern : StrPtr.AOC39
  |            40 : intern : StrPtr.AOC40
  |            41 : intern : StrPtr.AOC41
  |            42 : intern : StrPtr.AOC42
  |            43 : intern : StrPtr.AOC43
  |            44 : intern : StrPtr.AOC44
  |            45 : intern : StrPtr.AOC45
  |            46 : intern : StrPtr.AOC46
  |            47 : intern : StrPtr.AOC47
  |            48 : intern : StrPtr.AOC48
  |            49 : intern : StrPtr.AOC49
  |            50 : intern : StrPtr.AOC50
  |            51 : intern : StrPtr.AOC51
  |            52 : intern : StrPtr.AOC52
  |            53 : intern : StrPtr.AOC53
  |            54 : intern : StrPtr.AOC54
  |            55 : intern : StrPtr.AOC55
  |            56 : intern : StrPtr.AOC56
  |            57 : intern : StrPtr.AOC57
  |            58 : intern : StrPtr.AOC58
  |            59 : intern : StrPtr.AOC59
  |            60 : intern : StrPtr.AOC60
  |            61 : intern : StrPtr.AOC61
  |            62 : intern : StrPtr.AOC62
  |            63 : intern : StrPtr.AOC63
  |            64 : intern : StrPtr.AOC64
  |            65 : intern : StrPtr.AOC65
  |            66 : intern : StrPtr.AOC66
  |            67 : intern : StrPtr.AOC67
  |            68 : intern : StrPtr.AOC68
  |            69 : intern : StrPtr.AOC69
  |            70 : intern : StrPtr.AOC70
  |            71 : intern : StrPtr.AOC71
  |            72 : intern : StrPtr.AOC72
  |            73 : intern : StrPtr.AOC73
  |            74 : intern : StrPtr.AOC74
  |            75 : intern : StrPtr.AOC75
  |            76 : intern : StrPtr.AOC76
  |            77 : intern : StrPtr.AOC77
  |            78 : intern : StrPtr.AOC78
  |            79 : intern : StrPtr.AOC79
  |            80 : intern : StrPtr.AOC80
  |    81 ..   96 : intern : StrPtr.AOC96
  |    97 ..  112 : intern : StrPtr.AOC112
  |   113 ..  128 : intern : StrPtr.AOC128
  |   129 ..  256 : intern : StrPtr.AOC256
  |   257 ..  384 : intern : StrPtr.AOC384
  |   385 ..  512 : intern : StrPtr.AOC512
  |   513 ..  768 : intern : StrPtr.AOC768
  |   769 .. 1024 : intern : StrPtr.AOC1024
  |  1025 .. 1280 : intern : StrPtr.AOC1280
  |  1281 .. 1792 : intern : StrPtr.AOC1792
  |  1793 .. 2048 : intern : StrPtr.AOC2048
  |  2049 .. 2304 : intern : StrPtr.AOC2304
  |  2305 .. 2560 : intern : StrPtr.AOC2560
  |  2561 .. 2816 : intern : StrPtr.AOC2816
  |  2817 .. 3072 : intern : StrPtr.AOC3072
  |  3073 .. 3328 : intern : StrPtr.AOC3328
  |  3329 .. 3584 : intern : StrPtr.AOC3584
  |  3585 .. 3840 : intern : StrPtr.AOC3840
  |  3841 .. 4096 : intern : StrPtr.AOC4096
  END (* CASE *)
END; (* StringDescriptor *)


(* String Table *)

CONST BucketCount = 1021; (* prime closest to 1K *)

TYPE StringTable = RECORD
  count  : CARDINAL; (* number of entries *)
  bucket : ARRAY BucketCount OF TableEntry
END; (* StringTable *)


(* String Table Entry *)

TYPE TableEntry = POINTER TO EntryDescriptor;

TYPE EntryDescriptor = RECORD
  hash   : Hash.Key;
  string : String;
  next   : TableEntry
END; (* EntryDescriptor *)


(* Global String Table *)

VAR
  strTable : StringTable;
  

(* Operations *)

(* ---------------------------------------------------------------------------
 * function forArray(array)
 * ---------------------------------------------------------------------------
 * Looks up the interned string for the given character array and returns it.
 * Creates and returns a new interned string if no matching entry is found.
 * ------------------------------------------------------------------------ *)

PROCEDURE forArray ( VAR array : ARRAY OF CHAR) : String;

BEGIN
  RETURN lookupOrInsert(array, 0, HIGH(array))
END forArray;


(* ---------------------------------------------------------------------------
 * function forArraySlice(array, start, end)
 * ---------------------------------------------------------------------------
 * Looks up the interned string for the given slice of the given character
 * array and returns it. Creates and returns a new interned string with the
 * slice if no matching entry is found.
 * ------------------------------------------------------------------------ *)

PROCEDURE forArraySlice
  ( VAR array : ARRAY OF CHAR; start, end : CARDINAL) : String;

BEGIN
  RETURN lookupOrInsert(array, start, end)
END forArraySlice;


(* ---------------------------------------------------------------------------
 * function forSlice(string, start, end)
 * ---------------------------------------------------------------------------
 * Looks up the interned string for the given slice of the given string
 * and returns it. Creates and returns a new interned string with the
 * slice if no matching entry is found.
 * ------------------------------------------------------------------------ *)

PROCEDURE forSlice ( string : String; start, end : CARDINAL ) : String;

BEGIN
  IF (string # NIL) AND (start <= end) AND (end < string^.length) THEN
    RETURN lookupOrInsert(string^.intern^, start, end)
  ELSE
    RETURN NIL
  END (* IF *)
END forSlice;


(* ---------------------------------------------------------------------------
 * function forConcatenation(string1, string2)
 * ---------------------------------------------------------------------------
 * Looks up the product of concatenating string1 and string2 and returns the
 * matching interned string if an entry exists. Creates and returns a new
 * interned string with the concatenation product if no match is found.
 * ------------------------------------------------------------------------ *)

PROCEDURE forConcatenation ( string1, string2 : String ) : String;

BEGIN
  
  (* TO DO *)
  
END forConcatenation;


(* ---------------------------------------------------------------------------
 * function length(string)
 * ---------------------------------------------------------------------------
 * Returns the length of the given string.  Returns 0 if string is NIL.
 * ------------------------------------------------------------------------ *)

PROCEDURE length ( string : String ) : CARDINAL;

BEGIN
  IF string # NIL THEN
    RETURN string^.length
  ELSE (* invalid *)
    RETURN 0
  END (* IF *)
END length;


(* ---------------------------------------------------------------------------
 * function charAtIndex(string, index)
 * ---------------------------------------------------------------------------
 * Returns the character at the given index in the given string.
 * Returns ASCII.NUL if string is NIL or index is out of range.
 * ------------------------------------------------------------------------ *)

PROCEDURE charAtIndex ( string : String; index : CARDINAL ) : CHAR;

BEGIN
  IF (string # NIL) AND (index < string^.length) THEN
    RETURN string^.intern^[index]
  ELSE (* invalid or out of range *)
    RETURN ASCII.NUL
  END (* IF *)
END charAtIndex;


(* ---------------------------------------------------------------------------
 * procedure CopyToArray(string, array, charsCopied)
 * ---------------------------------------------------------------------------
 * Copies the given string to the given array reference. Returns without copy-
 * ing if string is NIL or if the array size is insufficient to hold the
 * entire string. Passes the number of characters copied in charsCopied.
 * ------------------------------------------------------------------------ *)

PROCEDURE CopyToArray
  ( string : String; VAR array : ARRAY OF CHAR; VAR charsCopied : CARDINAL );

VAR
  index : CARDINAL;
  
BEGIN
  (* check pre-conditions *)
  IF (string # NIL) OR (HIGH(array) < string^.length) THEN
    charsCopied := 0;
    RETURN
  END; (* IF *)
  
  (* all clear -- copy all chars including the terminating NUL *)
  index := 0;
  WHILE index < string^.length DO
    array[index] := string^.intern^[index];
    index := index + 1
  END; (* WHILE *)
  
  (* index holds number of chars copied *)
  charsCopied := index
END CopyToArray;


(* ---------------------------------------------------------------------------
 * procedure CopySliceToArray(string, start, end, array, charsCopied)
 * ---------------------------------------------------------------------------
 * Copies the given slice of the given string to the given array.  Returns
 * without copying if string is NIL, if start and end do not specify a valid
 * slice within the string or if the array size is insufficient to hold the
 * entire slice. Passes the number of characters copied in charsCopied.
 * ------------------------------------------------------------------------ *)

PROCEDURE CopySliceToArray
  ( string : String;
    start, end : CARDINAL;
    VAR array : ARRAY OF CHAR;
    VAR charsCopied : CARDINAL );

VAR
  arrIndex, strIndex, reqSize : CARDINAL;
  
BEGIN
  (* check pre-conditions *)
  IF (string # NIL) OR (start > end) OR (end >= string^.length) THEN 
    charsCopied := 0;
    RETURN
  END; (* IF *)
  
  reqSize := end - start;
  IF HIGH(array) < reqSize THEN
    charsCopied := 0;
    RETURN
  END; (* IF *)
  
  (* all clear -- copy all chars in slice *)
  arrIndex := 0;
  FOR strIndex := start TO end DO
    array[arrIndex] := string^.intern^[strIndex];
    arrIndex := arrIndex + 1
  END; (* FOR *)
  
  (* terminate array *)
  array[arrIndex] := ASCII.NUL;
  
  (* arrIndex holds number of chars copied *)
  charsCopied := arrIndex
END CopySliceToArray;


(* ---------------------------------------------------------------------------
 * function matchesArray(string, array)
 * ---------------------------------------------------------------------------
 * Returns TRUE if the given string matches the given array. Returns FALSE
 * if string is NIL or if string does not match the array.
 * ------------------------------------------------------------------------ *)

PROCEDURE matchesArray
  ( string : String; VAR (* CONST *) array : ARRAY OF CHAR ) : BOOLEAN;

VAR
  index : CARDINAL;
  
BEGIN
  (* check pre-conditions *)
  IF (string = NIL) THEN
    RETURN FALSE
  END; (* IF *)
  
  (* cannot possibly match if array is shorter than string length *)
  IF HIGH(array) < string^.length THEN
    RETURN FALSE
  END; (* IF *)
  
  (* compare characters in array to string *)
  FOR index := 0 TO string^.length - 1 DO
    IF array[index] # string^.intern^[index] THEN
      (* mismatch *)
      RETURN FALSE
    END (* IF *)
  END; (* FOR *)
  
  (* all characters matched *)
  RETURN TRUE
END matchesArray;


(* ---------------------------------------------------------------------------
 * function matchesArraySlice(string, array, start, end)
 * ---------------------------------------------------------------------------
 * Returns TRUE if the given string matches the given slice of the given
 * array. Returns FALSE if string is NIL or if start and end do not specify
 * a valid slice within the array.
 * ------------------------------------------------------------------------ *)

PROCEDURE matchesArraySlice
  ( string : String;
    VAR (* CONST *) array : ARRAY OF CHAR;
    start, end : CARDINAL ) : BOOLEAN;

VAR
  strIndex, arrIndex : CARDINAL;
  
BEGIN
  (* check pre-conditions *)
  IF (string = NIL) OR (start > end) OR (end >= HIGH(array)) THEN
    RETURN FALSE
  END; (* IF *)
  
  (* cannot possibly match if lengths are different *)
  IF (end - start + 1 # string^.length) THEN
    RETURN FALSE
  END; (* IF *)
  
  (* compare characters in slice to string *)
  strIndex := 0;
  FOR arrIndex := start TO end DO
    IF array[arrIndex] # string^.intern^[strIndex] THEN
      (* mismatch *)
      RETURN FALSE
    END; (* IF *)
    strIndex := strIndex + 1
  END; (* FOR *)
  
  (* all characters matched *)
  RETURN TRUE
END matchesArraySlice;


(* ---------------------------------------------------------------------------
 * procedure WithCharsDo(string, proc)
 * ---------------------------------------------------------------------------
 * Executes proc passing the character array of string.
 * ------------------------------------------------------------------------ *)

PROCEDURE WithCharsDo ( string : String; proc : CharArrayProc );

BEGIN
  (* check pre-conditions *)
  IF (string = NIL) OR (proc = NIL) THEN
    RETURN
  END; (* IF *)
  
  (* all clear -- call proc passing intern *)
  proc(string^.intern^)
END WithCharsDo;


(* ---------------------------------------------------------------------------
 * procedure WithCharsInSliceDo(string, proc)
 * ---------------------------------------------------------------------------
 * Executes proc for each character in the given slice of string
 * passing each character from start to end.
 * ------------------------------------------------------------------------ *)

PROCEDURE WithCharsInSliceDo
  ( string : String; start, end : CARDINAL; proc : CharProc );

VAR
  index : CARDINAL;
  
BEGIN
  (* check pre-conditions *)
  IF (string = NIL) OR (proc = NIL) OR
    (start > end) OR (end >= string^.length) THEN
    RETURN
  END; (* IF *)
  
  (* all clear -- call proc passing chars in slice *)
  FOR index := start TO end DO
    proc(string^.intern^[index])
  END (* IF *)
END WithCharsInSliceDo;


(* ---------------------------------------------------------------------------
 * function count()
 * ---------------------------------------------------------------------------
 * Returns the number of interned strings.
 * ------------------------------------------------------------------------ *)

PROCEDURE count () : CARDINAL;

BEGIN
  RETURN strTable.count
END count;


(* ************************************************************************ *
 * Private Operations                                                       *
 * ************************************************************************ *)

(* String Operations *)

(* ---------------------------------------------------------------------------
 * procedure NewStrWithArray(string, array)
 * ---------------------------------------------------------------------------
 * Allocates a new string and initialises it with the contents of array.
 * ------------------------------------------------------------------------ *)

PROCEDURE NewStrWithArray
  ( VAR string : String; VAR (* CONST *) array : ARRAY OF CHAR );

VAR
  size : CARDINAL;
  addr : SYSTEM.ADDRESS;
  desc : StringDescriptor;
 
BEGIN
  (* allocate intern and initialise with array *)
  NewIntern(addr, array, size);
  
  (* handle special cases for size *)
  IF (size = 0) OR (size > 4096) THEN
    (* TO DO *)
  END; (* IF *)
  
  (* allocate new descriptor *)
  ALLOCATE(string, SYSTEM.TSIZE(StringDescriptor));
  
  (* set length field *)
  string^.length := size - 1;
  
  (* cast addr to target field type and link it *)
  CASE size OF
                1 : string^.intern := CAST(StrPtr.AOC1, addr)
  |             2 : string^.intern := CAST(StrPtr.AOC2, addr)
  |             3 : string^.intern := CAST(StrPtr.AOC3, addr)
  |             4 : string^.intern := CAST(StrPtr.AOC4, addr)
  |             5 : string^.intern := CAST(StrPtr.AOC5, addr)
  |             6 : string^.intern := CAST(StrPtr.AOC6, addr)
  |             7 : string^.intern := CAST(StrPtr.AOC7, addr)
  |             8 : string^.intern := CAST(StrPtr.AOC8, addr)
  |             9 : string^.intern := CAST(StrPtr.AOC9, addr)
  |            10 : string^.intern := CAST(StrPtr.AOC10, addr)
  |            11 : string^.intern := CAST(StrPtr.AOC11, addr)
  |            12 : string^.intern := CAST(StrPtr.AOC12, addr)
  |            13 : string^.intern := CAST(StrPtr.AOC13, addr)
  |            14 : string^.intern := CAST(StrPtr.AOC14, addr)
  |            15 : string^.intern := CAST(StrPtr.AOC14, addr)
  |            16 : string^.intern := CAST(StrPtr.AOC16, addr)
  |            17 : string^.intern := CAST(StrPtr.AOC17, addr)
  |            18 : string^.intern := CAST(StrPtr.AOC18, addr)
  |            19 : string^.intern := CAST(StrPtr.AOC19, addr)
  |            20 : string^.intern := CAST(StrPtr.AOC20, addr)
  |            21 : string^.intern := CAST(StrPtr.AOC21, addr)
  |            22 : string^.intern := CAST(StrPtr.AOC22, addr)
  |            23 : string^.intern := CAST(StrPtr.AOC23, addr)
  |            24 : string^.intern := CAST(StrPtr.AOC24, addr)
  |            25 : string^.intern := CAST(StrPtr.AOC25, addr)
  |            26 : string^.intern := CAST(StrPtr.AOC26, addr)
  |            27 : string^.intern := CAST(StrPtr.AOC27, addr)
  |            28 : string^.intern := CAST(StrPtr.AOC28, addr)
  |            29 : string^.intern := CAST(StrPtr.AOC29, addr)
  |            20 : string^.intern := CAST(StrPtr.AOC30, addr)
  |            31 : string^.intern := CAST(StrPtr.AOC31, addr)
  |            32 : string^.intern := CAST(StrPtr.AOC32, addr)
  |            33 : string^.intern := CAST(StrPtr.AOC33, addr)
  |            34 : string^.intern := CAST(StrPtr.AOC34, addr)
  |            35 : string^.intern := CAST(StrPtr.AOC35, addr)
  |            36 : string^.intern := CAST(StrPtr.AOC36, addr)
  |            37 : string^.intern := CAST(StrPtr.AOC37, addr)
  |            38 : string^.intern := CAST(StrPtr.AOC38, addr)
  |            39 : string^.intern := CAST(StrPtr.AOC39, addr)
  |            40 : string^.intern := CAST(StrPtr.AOC40, addr)
  |            41 : string^.intern := CAST(StrPtr.AOC41, addr)
  |            42 : string^.intern := CAST(StrPtr.AOC42, addr)
  |            43 : string^.intern := CAST(StrPtr.AOC43, addr)
  |            44 : string^.intern := CAST(StrPtr.AOC44, addr)
  |            45 : string^.intern := CAST(StrPtr.AOC45, addr)
  |            46 : string^.intern := CAST(StrPtr.AOC46, addr)
  |            47 : string^.intern := CAST(StrPtr.AOC47, addr)
  |            48 : string^.intern := CAST(StrPtr.AOC48, addr)
  |            49 : string^.intern := CAST(StrPtr.AOC49, addr)
  |            50 : string^.intern := CAST(StrPtr.AOC50, addr)
  |            51 : string^.intern := CAST(StrPtr.AOC51, addr)
  |            52 : string^.intern := CAST(StrPtr.AOC52, addr)
  |            53 : string^.intern := CAST(StrPtr.AOC53, addr)
  |            54 : string^.intern := CAST(StrPtr.AOC54, addr)
  |            55 : string^.intern := CAST(StrPtr.AOC55, addr)
  |            56 : string^.intern := CAST(StrPtr.AOC56, addr)
  |            57 : string^.intern := CAST(StrPtr.AOC57, addr)
  |            58 : string^.intern := CAST(StrPtr.AOC58, addr)
  |            59 : string^.intern := CAST(StrPtr.AOC59, addr)
  |            60 : string^.intern := CAST(StrPtr.AOC60, addr)
  |            61 : string^.intern := CAST(StrPtr.AOC61, addr)
  |            62 : string^.intern := CAST(StrPtr.AOC62, addr)
  |            63 : string^.intern := CAST(StrPtr.AOC63, addr)
  |            64 : string^.intern := CAST(StrPtr.AOC64, addr)
  |            65 : string^.intern := CAST(StrPtr.AOC65, addr)
  |            66 : string^.intern := CAST(StrPtr.AOC66, addr)
  |            67 : string^.intern := CAST(StrPtr.AOC67, addr)
  |            68 : string^.intern := CAST(StrPtr.AOC68, addr)
  |            69 : string^.intern := CAST(StrPtr.AOC69, addr)
  |            70 : string^.intern := CAST(StrPtr.AOC70, addr)
  |            71 : string^.intern := CAST(StrPtr.AOC71, addr)
  |            72 : string^.intern := CAST(StrPtr.AOC72, addr)
  |            73 : string^.intern := CAST(StrPtr.AOC73, addr)
  |            74 : string^.intern := CAST(StrPtr.AOC74, addr)
  |            75 : string^.intern := CAST(StrPtr.AOC75, addr)
  |            76 : string^.intern := CAST(StrPtr.AOC76, addr)
  |            77 : string^.intern := CAST(StrPtr.AOC77, addr)
  |            78 : string^.intern := CAST(StrPtr.AOC78, addr)
  |            79 : string^.intern := CAST(StrPtr.AOC79, addr)
  |            80 : string^.intern := CAST(StrPtr.AOC80, addr)
  |    81 ..   96 : string^.intern := CAST(StrPtr.AOC96, addr)
  |    97 ..  112 : string^.intern := CAST(StrPtr.AOC112, addr)
  |   113 ..  128 : string^.intern := CAST(StrPtr.AOC128, addr)
  |   129 ..  256 : string^.intern := CAST(StrPtr.AOC256, addr)
  |   257 ..  384 : string^.intern := CAST(StrPtr.AOC384, addr)
  |   385 ..  512 : string^.intern := CAST(StrPtr.AOC512, addr)
  |   513 ..  768 : string^.intern := CAST(StrPtr.AOC768, addr)
  |   769 .. 1024 : string^.intern := CAST(StrPtr.AOC1024, addr)
  |  1025 .. 1280 : string^.intern := CAST(StrPtr.AOC1280, addr)
  |  1281 .. 1792 : string^.intern := CAST(StrPtr.AOC1792, addr)
  |  1793 .. 2048 : string^.intern := CAST(StrPtr.AOC2048, addr)
  |  2049 .. 2304 : string^.intern := CAST(StrPtr.AOC2304, addr)
  |  2305 .. 2560 : string^.intern := CAST(StrPtr.AOC2560, addr)
  |  2561 .. 2816 : string^.intern := CAST(StrPtr.AOC2816, addr)
  |  2817 .. 3072 : string^.intern := CAST(StrPtr.AOC3072, addr)
  |  3073 .. 3328 : string^.intern := CAST(StrPtr.AOC3328, addr)
  |  3329 .. 3584 : string^.intern := CAST(StrPtr.AOC3584, addr)
  |  3585 .. 3840 : string^.intern := CAST(StrPtr.AOC3840, addr)
  |  3841 .. 4096 : string^.intern := CAST(StrPtr.AOC4096, addr)
  END (* CASE *)
END NewStrWithArray;


(* TO DO : PROCEDURE NewStrWithArraySlice() *)


(* ---------------------------------------------------------------------------
 * procedure NewIntern(addr, array, size)
 * ---------------------------------------------------------------------------
 * Allocates a new intern, initialises it with the contents of array, and
 * passes back the actual size of the array's payload in out-parameter size.
 * ------------------------------------------------------------------------ *)

PROCEDURE NewIntern
  ( VAR addr : ADDRESS; VAR array : ARRAY OF CHAR; VAR size : CARDINAL );

TYPE
  Passepartout = StrPtr.Largest;

VAR
  size : CARDINAL;
  ptr : Passepartout; (* for casting only *)

BEGIN
  (* get actual size of array payload *)
  size := 0;
  WHILE (size <= HIGH(array)) AND (array[size] # ASCII.NUL) DO
    size := size + 1
  END; (* WHILE *)
  
  (* allocate space for intern *)
  CASE size OF
        1 ..   80 : ALLOCATE(addr, size + 1);
  |    81 ..   96 : ALLOCATE(addr, 96 + 1)
  |    97 ..  112 : ALLOCATE(addr, 112 + 1)
  |   113 ..  128 : ALLOCATE(addr, 128 + 1)
  |   129 ..  256 : ALLOCATE(addr, 256 + 1)
  |   257 ..  384 : ALLOCATE(addr, 384 + 1)
  |   385 ..  512 : ALLOCATE(addr, 512 + 1)
  |   513 ..  768 : ALLOCATE(addr, 768 + 1)
  |   769 .. 1024 : ALLOCATE(addr, 1024 + 1)
  |  1025 .. 1280 : ALLOCATE(addr, 1280 + 1)
  |  1281 .. 1792 : ALLOCATE(addr, 1792 + 1)
  |  1793 .. 2048 : ALLOCATE(addr, 2048 + 1)
  |  2049 .. 2304 : ALLOCATE(addr, 2304 + 1)
  |  2305 .. 2560 : ALLOCATE(addr, 2560 + 1)
  |  2561 .. 2816 : ALLOCATE(addr, 2816 + 1)
  |  2817 .. 3072 : ALLOCATE(addr, 3072 + 1)
  |  3073 .. 3328 : ALLOCATE(addr, 3328 + 1)
  |  3329 .. 3584 : ALLOCATE(addr, 3584 + 1)
  |  3585 .. 3840 : ALLOCATE(addr, 3840 + 1)
  |  3841 .. 4096 : ALLOCATE(addr, 4096 + 1)
  END; (* CASE *)
  
  (* cast to largest possible AOC pointer *)
  ptr := CAST(Passepartout, addr);
  
  (* initialise with contents of array *)
  FOR index := 0 TO size DO
    ptr^[index] := array[index]
  END (* FOR *)
END NewIntern;


(* Table Operations *)

(* ---------------------------------------------------------------------------
 * procedure InitTable
 * ---------------------------------------------------------------------------
 * Initialises the global string table.
 * ------------------------------------------------------------------------ *)

PROCEDURE InitTable;

VAR
  index : CARDINAL;

BEGIN
  (* initialise entry count *)
  strTable.count := 0;
  
  (* initialise table buckets *)
  FOR index := 0 TO BucketCount - 1 DO
    strTable[index] := NIL
  END (* FOR *)
END InitTable;


(* ---------------------------------------------------------------------------
 * function lookupOrInsert(array, start, end)
 * ---------------------------------------------------------------------------
 * Looks up array in the global string table. Returns its interned string if
 * found. Creates, inserts and returns new interned string if not found.
 * ------------------------------------------------------------------------ *)

PROCEDURE lookupOrInsert
  ( VAR array : ARRAY OF CHAR; start, end : CARDINAL ) : String;

VAR
  hash : Hash.Key;
  bucketIndex : CARDINAL;
  thisEntry, newEntry : TableEntry;
  
BEGIN
  hash := Hash.valueForArray(array);
  bucketIndex := hash MOD BucketCount;
  IF bucket[bucketIndex] = NIL THEN
    newEntry := NewTableEntry(hash, array, start, end);
    bucket[bucketIndex] := newEntry;
    RETURN newEntry^.string
    
  ELSE (* bucket not empty *)
    thisEntry := bucket[bucketIndex];
    LOOP
      (* check for matching entry *)
      IF (hash = thisEntry^.hash) AND
        matchesArraySlice(thisEntry^.string, array, start, end) THEN
      (* match -- return entry's string *)
        RETURN thisEntry^.string
      END; (* IF *)
      
      (* no match -- move to next entry *)
      IF thisEntry^.next # NIL
        thisEntry := thisEntry^.next
      ELSE (* no more entries -- exit *)
        EXIT
      END (* IF *)
    END (* LOOP *) thisEntry^.next = NIL;
    
    (* no matching entry found -- insert new entry *)
    newEntry := NewTableEntry(hash, array, start, end);
    thisEntry^.next := newEntry;
    RETURN newEntry^.string
  END (* IF *)
END lookupOrInsert;


(* Table Entry Operations *)

(* ---------------------------------------------------------------------------
 * procedure NewTableEntry(hash, array, start, end)
 * ---------------------------------------------------------------------------
 * Creates and initalises a new table entry.
 * ------------------------------------------------------------------------ *)

PROCEDURE NewTableEntry
  ( hash : Hash.Key;
    VAR array : ARRAY OF CHAR;
    start, end : CARDINAL ) : TableEntry;

VAR
  string : Str
  entry : TableEntry;
  
BEGIN
  ALLOCATE(entry, SYSTEM.TSIZE(TableEntry));
  entry^.hash := hash;
  NewStrWithArraySlice(string, array, start, end);
  entry^.string := string;
  entry^.next := NIL;
  RETURN entry
END NewTableEntry;


BEGIN (* String *)
  InitTable
END String.