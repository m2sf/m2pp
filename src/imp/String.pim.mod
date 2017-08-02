(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE String; (* PIM version *)

(* Interned Strings *)

IMPORT SYSTEM, StrBlank, Hash;

FROM ISO646 IMPORT NUL;
FROM Storage IMPORT ALLOCATE;


(* String *)

TYPE String = POINTER TO StringDescriptor;

TYPE Passepartout = POINTER TO StrBlank.Largest;

TYPE StringDescriptor = RECORD
  length : CARDINAL;
  intern : Passepartout
END; (* StringDescriptor *)


(* String Table Entry *)

TYPE TableEntry = POINTER TO EntryDescriptor;

TYPE EntryDescriptor = RECORD
  hash   : Hash.Key;
  string : String;
  next   : TableEntry
END; (* EntryDescriptor *)


(* String Table *)

CONST BucketCount = 1021; (* prime closest to 1K *)

TYPE StringTable = RECORD
  count  : CARDINAL; (* number of entries *)
  bucket : ARRAY [0..BucketCount-1] OF TableEntry
END; (* StringTable *)


(* Global String Table *)

VAR
  strTable : StringTable;
  

(* Operations *)

(* ---------------------------------------------------------------------------
 * function String.forConstArray(array)
 * ---------------------------------------------------------------------------
 * Looks up the interned string for a character array constant and returns it.
 * Creates and returns a new interned string if no matching entry is found.
 * ------------------------------------------------------------------------ *)

PROCEDURE forConstArray ( array : ARRAY OF CHAR ) : StringT;

BEGIN
  RETURN lookupOrInsert(array, 0, HIGH(array))
END forConstArray;


(* ---------------------------------------------------------------------------
 * function forArray(array)
 * ---------------------------------------------------------------------------
 * Looks up the interned string for the given character array and returns it.
 * Creates and returns a new interned string if no matching entry is found.
 * ------------------------------------------------------------------------ *)

PROCEDURE forArray ( VAR array : ARRAY OF CHAR ) : String;

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
  ( VAR array : ARRAY OF CHAR; start, end : CARDINAL ) : String;

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
 * function concat(string1, string2)
 * ---------------------------------------------------------------------------
 * Looks up the product of concatenating string1 and string2 and returns the
 * matching interned string if an entry exists. Creates and returns a new
 * interned string with the concatenation product if no match is found.
 * ------------------------------------------------------------------------ *)

PROCEDURE concat ( string1, string2 : String ) : String;

BEGIN
  (* TO DO *)
END concat;


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
 * Returns ASCII NUL if string is NIL or index is out of range.
 * ------------------------------------------------------------------------ *)

PROCEDURE charAtIndex ( string : String; index : CARDINAL ) : CHAR;

BEGIN
  IF (string # NIL) AND (index < string^.length) THEN
    RETURN string^.intern^[index]
  ELSE (* invalid or out of range *)
    RETURN NUL
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
  array[arrIndex] := NUL;
  
  (* arrIndex holds number of chars copied *)
  charsCopied := arrIndex
END CopySliceToArray;


(* ---------------------------------------------------------------------------
 * procedure AppendSliceToArray(string, start, end, array, charsCopied)
 * ---------------------------------------------------------------------------
 * Appends the given slice of the given string to the given array.  Returns
 * without copying if string is NIL, if start and end do not specify a valid
 * slice within the string or if the array size is insufficient to hold the
 * resulting string. Passes the number of characters copied in charsCopied.
 * ------------------------------------------------------------------------ *)

PROCEDURE AppendSliceToArray
  ( string : StringT;
    start, end : CARDINAL;
    VAR array : ARRAY OF CHAR;
    VAR charsCopied : CARDINAL );

VAR
  len : CARDINAL;
  
BEGIN
  (* check pre-conditions *)
  IF (string # NIL) OR (start > end) OR (end >= string^.length) THEN 
    charsCopied := 0;
    RETURN
  END; (* IF *)
  
  (* get length of array *)
  len := 0;
  WHILE (len <= HIGH(array)) AND (array[len] # NUL) DO
    len := len + 1
  END; (* WHILE *)
  
  reqSize := end - start + len;
  IF HIGH(array) < reqSize THEN
    charsCopied := 0;
    RETURN
  END; (* IF *)
  
  (* all clear -- copy all chars in slice *)
  arrIndex := len;
  FOR strIndex := start TO end DO
    array[arrIndex] := string^.intern^[strIndex];
    arrIndex := arrIndex + 1
  END; (* FOR *)
  
  (* terminate array *)
  array[arrIndex] := NUL;
  
  (* arrIndex holds number of chars copied *)
  charsCopied := arrIndex
END AppendSliceToArray;


(* ---------------------------------------------------------------------------
 * function String.matchesArray(string, array)
 * ---------------------------------------------------------------------------
 * Returns TRUE if the given string matches the given array constant. Returns
 * FALSE if string is NIL or if string does not match the array.
 * ------------------------------------------------------------------------ *)

PROCEDURE matchesConstArray
  ( string : StringT; array : ARRAY OF CHAR ) : BOOLEAN;

BEGIN
  RETURN matchesArray(string, array)
END matchesConstArray;


(* ---------------------------------------------------------------------------
 * function matchesArray(string, array)
 * ---------------------------------------------------------------------------
 * Returns TRUE if the given string matches the given array variable. Returns
 * FALSE if string is NIL or if string does not match the array.
 * ------------------------------------------------------------------------ *)

PROCEDURE matchesArray
  ( string : String; VAR (*CONST*) array : ARRAY OF CHAR ) : BOOLEAN;

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
    VAR (*CONST*) array : ARRAY OF CHAR;
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
 * function comparison(left, right)
 * ---------------------------------------------------------------------------
 * Compares strings left and right using ASCII collation order, returns Equal
 * if the strings match,  Less if left < right,  or Greater if left > right.
 * ------------------------------------------------------------------------ *)

PROCEDURE comparison ( left, right : String ) : Comparison;

BEGIN
  (* TO DO *)
END comparison;


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
  
  (* call proc passing intern *)
  
  (* we need to cast intern to the AOC type matching its allocation length
     before passing it to proc, or else the compiler will use an incorrect
     value for HIGH and intern won't be type safe within proc. *)
  
  IF string^.length < 80 THEN
    CASE string^.length OF
       0 : proc(StrBlank.AOC0(string^.intern^))
    |  1 : proc(StrBlank.AOC1(string^.intern^))
    |  2 : proc(StrBlank.AOC2(string^.intern^))
    |  3 : proc(StrBlank.AOC3(string^.intern^))
    |  4 : proc(StrBlank.AOC4(string^.intern^))
    |  5 : proc(StrBlank.AOC5(string^.intern^))
    |  6 : proc(StrBlank.AOC6(string^.intern^))
    |  7 : proc(StrBlank.AOC7(string^.intern^))
    |  8 : proc(StrBlank.AOC8(string^.intern^))
    |  9 : proc(StrBlank.AOC9(string^.intern^))
    | 10 : proc(StrBlank.AOC10(string^.intern^))
    | 11 : proc(StrBlank.AOC11(string^.intern^))
    | 12 : proc(StrBlank.AOC12(string^.intern^))
    | 13 : proc(StrBlank.AOC13(string^.intern^))
    | 14 : proc(StrBlank.AOC14(string^.intern^))
    | 15 : proc(StrBlank.AOC14(string^.intern^))
    | 16 : proc(StrBlank.AOC16(string^.intern^))
    | 17 : proc(StrBlank.AOC17(string^.intern^))
    | 18 : proc(StrBlank.AOC18(string^.intern^))
    | 19 : proc(StrBlank.AOC19(string^.intern^))
    | 20 : proc(StrBlank.AOC20(string^.intern^))
    | 21 : proc(StrBlank.AOC21(string^.intern^))
    | 22 : proc(StrBlank.AOC22(string^.intern^))
    | 23 : proc(StrBlank.AOC23(string^.intern^))
    | 24 : proc(StrBlank.AOC24(string^.intern^))
    | 25 : proc(StrBlank.AOC25(string^.intern^))
    | 26 : proc(StrBlank.AOC26(string^.intern^))
    | 27 : proc(StrBlank.AOC27(string^.intern^))
    | 28 : proc(StrBlank.AOC28(string^.intern^))
    | 29 : proc(StrBlank.AOC29(string^.intern^))
    | 30 : proc(StrBlank.AOC30(string^.intern^))
    | 31 : proc(StrBlank.AOC31(string^.intern^))
    | 32 : proc(StrBlank.AOC32(string^.intern^))
    | 33 : proc(StrBlank.AOC33(string^.intern^))
    | 34 : proc(StrBlank.AOC34(string^.intern^))
    | 35 : proc(StrBlank.AOC35(string^.intern^))
    | 36 : proc(StrBlank.AOC36(string^.intern^))
    | 37 : proc(StrBlank.AOC37(string^.intern^))
    | 38 : proc(StrBlank.AOC38(string^.intern^))
    | 39 : proc(StrBlank.AOC39(string^.intern^))
    | 40 : proc(StrBlank.AOC40(string^.intern^))
    | 41 : proc(StrBlank.AOC41(string^.intern^))
    | 42 : proc(StrBlank.AOC42(string^.intern^))
    | 43 : proc(StrBlank.AOC43(string^.intern^))
    | 44 : proc(StrBlank.AOC44(string^.intern^))
    | 45 : proc(StrBlank.AOC45(string^.intern^))
    | 46 : proc(StrBlank.AOC46(string^.intern^))
    | 47 : proc(StrBlank.AOC47(string^.intern^))
    | 48 : proc(StrBlank.AOC48(string^.intern^))
    | 49 : proc(StrBlank.AOC49(string^.intern^))
    | 50 : proc(StrBlank.AOC50(string^.intern^))
    | 51 : proc(StrBlank.AOC51(string^.intern^))
    | 52 : proc(StrBlank.AOC52(string^.intern^))
    | 53 : proc(StrBlank.AOC53(string^.intern^))
    | 54 : proc(StrBlank.AOC54(string^.intern^))
    | 55 : proc(StrBlank.AOC55(string^.intern^))
    | 56 : proc(StrBlank.AOC56(string^.intern^))
    | 57 : proc(StrBlank.AOC57(string^.intern^))
    | 58 : proc(StrBlank.AOC58(string^.intern^))
    | 59 : proc(StrBlank.AOC59(string^.intern^))
    | 60 : proc(StrBlank.AOC60(string^.intern^))
    | 61 : proc(StrBlank.AOC61(string^.intern^))
    | 62 : proc(StrBlank.AOC62(string^.intern^))
    | 63 : proc(StrBlank.AOC63(string^.intern^))
    | 64 : proc(StrBlank.AOC64(string^.intern^))
    | 65 : proc(StrBlank.AOC65(string^.intern^))
    | 66 : proc(StrBlank.AOC66(string^.intern^))
    | 67 : proc(StrBlank.AOC67(string^.intern^))
    | 68 : proc(StrBlank.AOC68(string^.intern^))
    | 69 : proc(StrBlank.AOC69(string^.intern^))
    | 70 : proc(StrBlank.AOC70(string^.intern^))
    | 71 : proc(StrBlank.AOC71(string^.intern^))
    | 72 : proc(StrBlank.AOC72(string^.intern^))
    | 73 : proc(StrBlank.AOC73(string^.intern^))
    | 74 : proc(StrBlank.AOC74(string^.intern^))
    | 75 : proc(StrBlank.AOC75(string^.intern^))
    | 76 : proc(StrBlank.AOC76(string^.intern^))
    | 77 : proc(StrBlank.AOC77(string^.intern^))
    | 78 : proc(StrBlank.AOC78(string^.intern^))
    | 79 : proc(StrBlank.AOC79(string^.intern^))
    END (* CASE *)
  ELSE
    IF string^.length < 768 THEN
      IF string^.length < 128 THEN
        IF string^.length < 96 THEN
          IF string^.length < 88 THEN
            proc(StrBlank.AOC87(string^.intern^))
          ELSE (* string^.length >= 88 *)
            proc(StrBlank.AOC95(string^.intern^))
          END (* IF *)
        ELSE (* string^.length >= 96 *)
          IF string^.length < 112 THEN
            proc(StrBlank.AOC111(string^.intern^))
          ELSE (* string^.length >= 112 *)
            proc(StrBlank.AOC127(string^.intern^))
          END (* IF *)
        END (* IF *)
      ELSE (* string^.length >= 128 *)
        IF string^.length < 256 THEN
          IF string^.length < 192 THEN
            proc(StrBlank.AOC191(string^.intern^))
          ELSE (* string^.length >= 192 *)
            proc(StrBlank.AOC255(string^.intern^))
          END (* IF *)
        ELSE (* string^.length >= 256 *)
          IF string^.length < 512 THEN
            proc(StrBlank.AOC511(string^.intern^))
          ELSE (* string^.length >= 512 *)
            proc(StrBlank.AOC767(string^.intern^))
          END (* IF *)
        END (* IF *)
      END (* IF *)
    ELSE (* strlen >= 768 *)
      IF string^.length < 1792 THEN
        IF string^.length < 1280 THEN
          IF string^.length < 1024 THEN
            proc(StrBlank.AOC1023(string^.intern^))
          ELSE (* string^.length >= 1024 *)
            proc(StrBlank.AOC1279(string^.intern^))
          END (* IF *)
        ELSE (* string^.length >= 1280 *)
          IF string^.length < 1536 THEN
            proc(StrBlank.AOC1535(string^.intern^))
          ELSE (* string^.length >= 1536 *)
            proc(StrBlank.AOC1791(string^.intern^))
          END (* IF *)
        END (* IF *)
      ELSE (* string^.length >= 1792 *)
        IF string^.length < 2560 THEN
          IF string^.length < 2048 THEN
            proc(StrBlank.AOC2047(string^.intern^))
          ELSE (* string^.length >= 2048 *)
            proc(StrBlank.AOC2559(string^.intern^))
          END (* IF *)
        ELSE (* string^.length >= 2560 *)
          IF string^.length < 3072 THEN
            proc(StrBlank.AOC3071(string^.intern^))
          ELSE (* string^.length >= 3072 *)
            proc(StrBlank.Largest(string^.intern^))
          END (* IF *)
        END (* IF *)
      END (* IF *)
    END (* IF *)
  END (* IF *)
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
    strTable.bucket[index] := NIL
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
  len, bucketIndex : CARDINAL;
  thisEntry, newEntry : TableEntry;
  
BEGIN
  (* start must not exceed end *)
  IF start > end THEN
    RETURN NIL
  END; (* IF *)
  
  (* determine length of array *)
  len := 0;
  WHILE (len <= HIGH(array)) AND (array[len] # NUL) DO
    len := len + 1
  END; (* WHILE *)
  
  (* limit length to MaxLength *)
  IF len > MaxLength THEN
    len := MaxLength
  END; (* IF *)
  
  (* limit end to MaxLength-1 *)
  IF end >= MaxLength THEN
    end := MaxLength - 1
  END; (* IF *)
  
  (* end must not fall outside of valid character range *)
  IF ((len > 0) AND (end >= len)) OR ((len = 0) AND (end > 0)) THEN
    RETURN NIL
  END; (* IF *)
  
  (* calculate hash and bucket *)
  hash := Hash.valueForArraySlice(array, start, end);
  bucketIndex := Hash.mod(hash, BucketCount);
  
  (* check if bucket is empty *)
  IF bucket[bucketIndex] = NIL THEN
    NewTableEntry(newEntry, hash, array, start, end);
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
      IF thisEntry^.next # NIL THEN
        thisEntry := thisEntry^.next
      ELSE (* no more entries -- exit *)
        EXIT
      END (* IF *)
    END; (* LOOP *)
    
    (* no matching entry found -- insert new entry *)
    NewTableEntry(newEntry, hash, array, start, end);
    thisEntry^.next := newEntry;
    RETURN newEntry^.string
  END (* IF *)
END lookupOrInsert;


(* Table Entry Operations *)

(* ---------------------------------------------------------------------------
 * procedure NewTableEntry(hash, array, start, end)
 * ---------------------------------------------------------------------------
 * Creates a new table entry, initialises it w/ contents of array[start..end].
 * Passes the new entry in entry, or NIL if allocation failed.
 *
 * pre-conditions:
 *   (1) start must not exceed end
 *   (2) end must not exceed HIGH(array)
 *   (3a) if array is empty, start and end must both be zero
 *   (3b) otherwise end must be smaller than the index of any NUL terminator
 *   (4) hash must contain the correct hash key for slice array[start..end]
 *
 * PRE-CONDITIONS ARE NOT CHECKED - THEY MUST BE ASSERTED BY THE CALLER !!!!!
 * ------------------------------------------------------------------------ *)

PROCEDURE NewTableEntry
  ( VAR entry  : TableEntry;    (* out : new table entry or NIL *)
    hash       : Hash.Key;      (* in  : hash key of array[start..end] *)
    VAR array  : ARRAY OF CHAR; (* in  : char array for initialisation *)
    start,                      (* in  : start index of slice to copy *)
    end        : CARDINAL );    (* in  : end index of slice to copy *)

VAR
  string : String;
  newEntry : TableEntry;
  
BEGIN
  ALLOCATE(newEntry, SYSTEM.TSIZE(TableEntry));
  
  IF newEntry = NIL THEN
    entry := NIL;
    RETURN
  END; (* IF *)
  
  NewStrWithArraySlice(string, array, start, end);
  
  IF string = NIL THEN
    entry := NIL;
    RETURN
  END; (* IF *)
  
  newEntry^.hash := hash;
  newEntry^.string := string;
  newEntry^.next := NIL;
  
  entry := newEntry
END NewTableEntry;


(* String Operations *)

(* ---------------------------------------------------------------------------
 * procedure NewStrWithArraySlice(string, array, start, end)
 * ---------------------------------------------------------------------------
 * Allocates a new string, initialises it with contents of array[start..end].
 * Passes back the new string in string, or NIL if allocation failed.
 *
 * pre-conditions:
 *   (1) start must not exceed end
 *   (2) end must not exceed HIGH(array)
 *   (3a) if array is empty, start and end must both be zero
 *   (3b) otherwise end must be smaller than the index of any NUL terminator
 *
 * PRE-CONDITIONS ARE NOT CHECKED - THEY MUST BE ASSERTED BY THE CALLER !!!!!
 * ------------------------------------------------------------------------ *)

PROCEDURE NewStrWithArraySlice
  ( VAR string : String;        (* out : newly allocated string *)
    VAR array  : ARRAY OF CHAR; (* in  : source array for initialisation *)
    start,                      (* in  : start index of slice to copy *)
    end        : CARDINAL );    (* in  : end index of slice to copy *)

VAR
  newString : String;
  ptr : Passepartout;
  addr : SYSTEM.ADDRESS;
  strlen, size, srcIndex, tgtIndex : CARDINAL;

BEGIN  
  (* determine length of new string *)
  IF array[0] # NUL THEN
    strlen := end - start + 1
  ELSE
    strlen := 0
  END; (* IF *)
  
  (* determine allocation size *)
  size := StrBlank.allocSizeForStrLen(strlen);
  
  (* allocate space for intern *)
  ALLOCATE(addr, size);
  
  IF addr = NIL THEN
    RETURN
  END; (* IF *)
  
  (* cast to largest possible AOC pointer *)
  ptr := Passepartout(addr);
  
  (* initialise intern with array[start..end] *)
  IF strlen > 0 THEN
    tgtIndex := 0;
    FOR srcIndex := start TO end DO
      ptr^[tgtIndex] := array[srcIndex];
      tgtIndex := tgtIndex + 1
    END (* FOR *)
  END; (* IF *)
  
  (* NUL terminate the intern *)
  ptr^[strlen] := NUL;
  
  (* bail out if allocation failed *)
  IF addr = NIL THEN
    string := NIL;
    RETURN
  END; (* IF *)
  
  (* allocate new string descriptor *)
  ALLOCATE(newString, SYSTEM.TSIZE(StringDescriptor));
  
  (* bail out if allocation failed *)
  IF newString = NIL THEN
    string := NIL;
    RETURN
  END; (* IF *)
  
  (* set length field *)
  newString^.length := strlen;
  
  (* cast newString^.intern to target field type and link it *)
  newString^.intern := Passepartout(addr);
  
  string := newString
END NewStrWithArraySlice;


BEGIN (* String *)
  InitTable
END String.