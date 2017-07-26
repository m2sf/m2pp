(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE String; (* PIM version *)

(* Interned Strings *)

IMPORT SYSTEM, StrPtr, Hash;

FROM ISO646 IMPORT NUL;
FROM Storage IMPORT ALLOCATE;


(* String *)

TYPE String = POINTER TO StringDescriptor;

TYPE StringDescriptor = RECORD
  length : CARDINAL;
  intern : StrPtr.Largest
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
       0 : proc(StrPtr.AOC0(string^.intern)^)
    |  1 : proc(StrPtr.AOC1(string^.intern)^)
    |  2 : proc(StrPtr.AOC2(string^.intern)^)
    |  3 : proc(StrPtr.AOC3(string^.intern)^)
    |  4 : proc(StrPtr.AOC4(string^.intern)^)
    |  5 : proc(StrPtr.AOC5(string^.intern)^)
    |  6 : proc(StrPtr.AOC6(string^.intern)^)
    |  7 : proc(StrPtr.AOC7(string^.intern)^)
    |  8 : proc(StrPtr.AOC8(string^.intern)^)
    |  9 : proc(StrPtr.AOC9(string^.intern)^)
    | 10 : proc(StrPtr.AOC10(string^.intern)^)
    | 11 : proc(StrPtr.AOC11(string^.intern)^)
    | 12 : proc(StrPtr.AOC12(string^.intern)^)
    | 13 : proc(StrPtr.AOC13(string^.intern)^)
    | 14 : proc(StrPtr.AOC14(string^.intern)^)
    | 15 : proc(StrPtr.AOC14(string^.intern)^)
    | 16 : proc(StrPtr.AOC16(string^.intern)^)
    | 17 : proc(StrPtr.AOC17(string^.intern)^)
    | 18 : proc(StrPtr.AOC18(string^.intern)^)
    | 19 : proc(StrPtr.AOC19(string^.intern)^)
    | 20 : proc(StrPtr.AOC20(string^.intern)^)
    | 21 : proc(StrPtr.AOC21(string^.intern)^)
    | 22 : proc(StrPtr.AOC22(string^.intern)^)
    | 23 : proc(StrPtr.AOC23(string^.intern)^)
    | 24 : proc(StrPtr.AOC24(string^.intern)^)
    | 25 : proc(StrPtr.AOC25(string^.intern)^)
    | 26 : proc(StrPtr.AOC26(string^.intern)^)
    | 27 : proc(StrPtr.AOC27(string^.intern)^)
    | 28 : proc(StrPtr.AOC28(string^.intern)^)
    | 29 : proc(StrPtr.AOC29(string^.intern)^)
    | 20 : proc(StrPtr.AOC30(string^.intern)^)
    | 31 : proc(StrPtr.AOC31(string^.intern)^)
    | 32 : proc(StrPtr.AOC32(string^.intern)^)
    | 33 : proc(StrPtr.AOC33(string^.intern)^)
    | 34 : proc(StrPtr.AOC34(string^.intern)^)
    | 35 : proc(StrPtr.AOC35(string^.intern)^)
    | 36 : proc(StrPtr.AOC36(string^.intern)^)
    | 37 : proc(StrPtr.AOC37(string^.intern)^)
    | 38 : proc(StrPtr.AOC38(string^.intern)^)
    | 39 : proc(StrPtr.AOC39(string^.intern)^)
    | 40 : proc(StrPtr.AOC40(string^.intern)^)
    | 41 : proc(StrPtr.AOC41(string^.intern)^)
    | 42 : proc(StrPtr.AOC42(string^.intern)^)
    | 43 : proc(StrPtr.AOC43(string^.intern)^)
    | 44 : proc(StrPtr.AOC44(string^.intern)^)
    | 45 : proc(StrPtr.AOC45(string^.intern)^)
    | 46 : proc(StrPtr.AOC46(string^.intern)^)
    | 47 : proc(StrPtr.AOC47(string^.intern)^)
    | 48 : proc(StrPtr.AOC48(string^.intern)^)
    | 49 : proc(StrPtr.AOC49(string^.intern)^)
    | 50 : proc(StrPtr.AOC50(string^.intern)^)
    | 51 : proc(StrPtr.AOC51(string^.intern)^)
    | 52 : proc(StrPtr.AOC52(string^.intern)^)
    | 53 : proc(StrPtr.AOC53(string^.intern)^)
    | 54 : proc(StrPtr.AOC54(string^.intern)^)
    | 55 : proc(StrPtr.AOC55(string^.intern)^)
    | 56 : proc(StrPtr.AOC56(string^.intern)^)
    | 57 : proc(StrPtr.AOC57(string^.intern)^)
    | 58 : proc(StrPtr.AOC58(string^.intern)^)
    | 59 : proc(StrPtr.AOC59(string^.intern)^)
    | 60 : proc(StrPtr.AOC60(string^.intern)^)
    | 61 : proc(StrPtr.AOC61(string^.intern)^)
    | 62 : proc(StrPtr.AOC62(string^.intern)^)
    | 63 : proc(StrPtr.AOC63(string^.intern)^)
    | 64 : proc(StrPtr.AOC64(string^.intern)^)
    | 65 : proc(StrPtr.AOC65(string^.intern)^)
    | 66 : proc(StrPtr.AOC66(string^.intern)^)
    | 67 : proc(StrPtr.AOC67(string^.intern)^)
    | 68 : proc(StrPtr.AOC68(string^.intern)^)
    | 69 : proc(StrPtr.AOC69(string^.intern)^)
    | 70 : proc(StrPtr.AOC70(string^.intern)^)
    | 71 : proc(StrPtr.AOC71(string^.intern)^)
    | 72 : proc(StrPtr.AOC72(string^.intern)^)
    | 73 : proc(StrPtr.AOC73(string^.intern)^)
    | 74 : proc(StrPtr.AOC74(string^.intern)^)
    | 75 : proc(StrPtr.AOC75(string^.intern)^)
    | 76 : proc(StrPtr.AOC76(string^.intern)^)
    | 77 : proc(StrPtr.AOC77(string^.intern)^)
    | 78 : proc(StrPtr.AOC78(string^.intern)^)
    | 79 : proc(StrPtr.AOC79(string^.intern)^)
    END (* CASE *)
  ELSE
    IF string^.length < 768 THEN
      IF string^.length < 128 THEN
        IF string^.length < 96 THEN
          IF string^.length < 88 THEN
            proc(StrPtr.AOC87(string^.intern)^)
          ELSE (* string^.length >= 88 *)
            proc(StrPtr.AOC95(string^.intern)^)
          END (* IF *)
        ELSE (* string^.length >= 96 *)
          IF string^.length < 112 THEN
            proc(StrPtr.AOC111(string^.intern)^)
          ELSE (* string^.length >= 112 *)
            proc(StrPtr.AOC127(string^.intern)^)
          END (* IF *)
        END (* IF *)
      ELSE (* string^.length >= 128 *)
        IF string^.length < 256 THEN
          IF string^.length < 192 THEN
            proc(StrPtr.AOC191(string^.intern)^)
          ELSE (* string^.length >= 192 *)
            proc(StrPtr.AOC255(string^.intern)^)
          END (* IF *)
        ELSE (* string^.length >= 256 *)
          IF string^.length < 512 THEN
            proc(StrPtr.AOC511(string^.intern)^)
          ELSE (* string^.length >= 512 *)
            (* case 8 *) size := 768
            proc(StrPtr.AOC767(string^.intern)^)
          END (* IF *)
        END (* IF *)
      END (* IF *)
    ELSE (* strlen >= 768 *)
      IF string^.length < 1792 THEN
        IF string^.length < 1280 THEN
          IF string^.length < 1024 THEN
            proc(StrPtr.AOC1023(string^.intern)^)
          ELSE (* string^.length >= 1024 *)
            proc(StrPtr.AOC1279(string^.intern)^)
          END (* IF *)
        ELSE (* string^.length >= 1280 *)
          IF string^.length < 1536 THEN
            proc(StrPtr.AOC1535(string^.intern)^)
          ELSE (* string^.length >= 1536 *)
            proc(StrPtr.AOC1791(string^.intern)^)
          END (* IF *)
        END (* IF *)
      ELSE (* string^.length >= 1792 *)
        IF string^.length < 2560 THEN
          IF string^.length < 2048 THEN
            proc(StrPtr.AOC2047(string^.intern)^)
          ELSE (* string^.length >= 2048 *)
            proc(StrPtr.AOC2559(string^.intern)^)
          END (* IF *)
        ELSE (* string^.length >= 2560 *)
          IF string^.length < 3072 THEN
            proc(StrPtr.AOC3071(string^.intern)^)
          ELSE (* string^.length >= 3072 *)
            proc(StrPtr.Largest(string^.intern)^)
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
  bucketIndex := hash MOD BucketCount;
  
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
      IF thisEntry^.next # NIL
        thisEntry := thisEntry^.next
      ELSE (* no more entries -- exit *)
        EXIT
      END (* IF *)
    END (* LOOP *) thisEntry^.next = NIL;
    
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
  ( VAR        : entry : TableEntry; (* out : new table entry or NIL *)
    hash       : Hash.Key;           (* in  : hash key of array[start..end] *)
    VAR array  : ARRAY OF CHAR;      (* in  : char array for initialisation *)
    start,                           (* in  : start index of slice to copy *)
    end        : CARDINAL );         (* in  : end index of slice to copy *)

VAR
  string : Str
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
  ptr : StrPtr.Largest;
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
  size := allocSizeForStrLen(strlen);
  
  (* allocate space for intern *)
  ALLOCATE(addr, size);
  
  IF addr = NIL THEN
    RETURN
  END; (* IF *)
  
  (* cast to largest possible AOC pointer *)
  ptr := StrPtr.Largest(addr);
  
  (* initialise intern with array[start..end] *)
  IF strlen > 0 THEN
    tgtIndex := 0;
    FOR srcIndex := start TO end DO
      ptr^[tgtIndex] := array[srcIndex];
      tgtIndex := tgtIndex + 1
    END (* FOR *)
  END; (* IF *)
  
  (* NUL terminate the intern *)
  ptr^[strlen] := NUL
  
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
  newString^.intern := StrPtr.Largest(addr);
  
  string := newString
END NewStrWithArraySlice;


BEGIN (* String *)
  InitTable
END String.