(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation. *)

IMPLEMENTATION MODULE CharArray;

(* Character Array Operations *)

FROM ISO646 IMPORT NUL, SPACE, DOUBLEQUOTE;


(* Introspection *)

PROCEDURE length ( VAR (* CONST *) array : ARRAY OF CHAR ) : CARDINAL;
(* Returns the number of characters in array. *)

VAR
  len : CARDINAL;
  
BEGIN
  len := 0;
  WHILE (len < HIGH(array)) AND (array[len] # NUL) DO
    len := len + 1
  END; (* WHILE *)
  
  RETURN len
END length;


PROCEDURE words ( VAR (* CONST *) array : ARRAY OF CHAR ) : CARDINAL;
(* Returns the number of words in array. *)

BEGIN
  (* TO DO *)
END words;


PROCEDURE lengthOfWordAtIndex
  ( VAR (* CONST *) array : ARRAY OF CHAR; n : CARDINAL ) : CARDINAL;
(* Returns the number of characters in the n-th word in array. *)

BEGIN
  (* TO DO *)
END lengthOfWordAtIndex;


(* Trimming, Collapsing and Stripping *)

PROCEDURE Trim ( VAR array : ARRAY OF CHAR );
(* Removes leading and trailing whitespace from array. *)

VAR
  len, startIndex, tgtIndex, srcIndex : CARDINAL;
  
BEGIN
  len := length(array);
  
  (* nothing to do if empty *)
  IF len = 0 THEN
    RETURN
  END; (* IF *)
  
  (* remove trailing space *)
  WHILE (len > 0) AND (array[len-1] = SPACE) DO
    array[len-1] := NUL;
    len := len - 1
  END; (* WHILE *)
  
  (* find left-most non-space character *)
  startIndex := 0;
  WHILE (startIndex < len) AND (array[startIndex] = SPACE) DO
    startIndex := startIndex + 1
  END; (* WHILE *)
  
  (* no leading space, nothing further to do *)
  IF startIndex = 0 THEN
    RETURN
  END; (* IF *)
  
  (* copy array[startIndex..len] to array[0..] *)
  tgtIndex := 0;
  FOR srcIndex := startIndex TO len DO
    array[tgtIndex] := array[srcIndex];
    tgtIndex := tgtIndex + 1
  END (* FOR *)
END Trim;


PROCEDURE Collapse ( VAR array : ARRAY OF CHAR );
(* Replaces consecutive whitespace in array with single whitespace. *)

VAR
  found : BOOLEAN;
  ch, nextChar : CHAR;
  len, index, srcIndex, tgtIndex : CARDINAL;

BEGIN
  Trim(array);
  len := length(array);
  
  (* nothing further to do if empty *)
  IF len = 0 THEN
    RETURN
  END; (* IF *)
  
  (* find first consecutive space *)
  tgtIndex := 0;
  FindFirstConsecutiveSpace(array, found, tgtIndex);
  
  (* nothing further to do if no consecutive space found *)
  IF NOT found THEN
    RETURN
  END; (* IF *)
  
  REPEAT
    (* find first non-space to the right *)
    srcIndex := 0;
    WHILE (srcIndex <= HIGH(array)) AND (array[srcIndex] = SPACE) DO
      srcIndex := srcIndex + 1
    END; (* WHILE *)
    
    (* copy following characters up to next consecutive space *)
    found := FALSE;
    ch := array[srcIndex];
    WHILE NOT found AND (ch # NUL) AND (srcIndex < HIGH(array)) DO
      array[tgtIndex] := ch;
      srcIndex := srcIndex + 1;
      nextChar := array[srcIndex];
      found := ((ch = SPACE) AND (array[srcIndex] = SPACE));
      tgtIndex := tgtIndex + 1;
      ch := nextChar
    END (* WHILE *)
  UNTIL NOT found;
  
  array[tgtIndex] := NUL
END Collapse;


PROCEDURE StripWhitespace ( VAR array : ARRAY OF CHAR );
(* Removes all whitespace from array. *)

BEGIN
  (* TO DO *)
END StripWhitespace;


PROCEDURE StripNonAlphaNum ( VAR array : ARRAY OF CHAR );
(* Removes all non-alphanumeric characters, including whitespace from array. *)

BEGIN
  (* TO DO *)
END StripNonAlphaNum;


PROCEDURE ToWordSequence ( VAR array : ARRAY OF CHAR );
(* Replaces any minus, plus, asterisk, solidus, single and double quote that
   is enclosed by letters to whitespace, then trim-collapses whitespace, and
   then removes non-aphanumeric characters except whitespace from array. *)

BEGIN
  (* TO DO *)
END ToWordSequence;


(* Case Transformations *)

PROCEDURE ToLower ( VAR array : ARRAY OF CHAR );
(* Converts all uppercase characters in array to lowercase. *)

VAR
  ch : CHAR;
  index : CARDINAL;
  
BEGIN
  FOR index := 0 TO HIGH(array) DO
    ch := array[index];
    IF ch = NUL THEN
      RETURN
    ELSIF (ch >= 'A') AND (ch <= 'Z') THEN
      array[index] := CHR(ORD(ch) + 32)
    END (* IF *)
  END (* FOR *)
END ToLower;


PROCEDURE ToUpper ( VAR array : ARRAY OF CHAR );
(* Converts all lowercase characters in array to uppercase. *)

VAR
  ch : CHAR;
  index : CARDINAL;
  
BEGIN
  FOR index := 0 TO HIGH(array) DO
    ch := array[index];
    IF ch = NUL THEN
      RETURN
    ELSIF (ch >= 'a') AND (ch <= 'z') THEN
      array[index] := CHR(ORD(ch) - 32)
    END (* IF *)
  END (* FOR *)
END ToUpper;


PROCEDURE ToCapital ( VAR array : ARRAY OF CHAR );
(* Converts first letter in array to uppercase, all others to lowercase. *)

BEGIN
  (* TO DO *)
END ToCapital;


PROCEDURE ToCamel ( VAR array : ARRAY OF CHAR );
(* Converts word sequence in array to camelCase. *)

BEGIN
  (* TO DO *)
END ToCamel;


PROCEDURE ToTitle ( VAR array : ARRAY OF CHAR );
(* Converts word sequence in array to TitleCase. *)

BEGIN
  (* TO DO *)
END ToTitle;


(* Copy Operations *)

PROCEDURE canCopyArray
  ( VAR (*CONST*) target : ARRAY OF CHAR; source : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if target can store the contents of source. *)

BEGIN
  RETURN (HIGH(target) > length(source))
END canCopyArray;


PROCEDURE CopyArray
  ( VAR target : ARRAY OF CHAR; source : ARRAY OF CHAR );
(* Copies source to target. *)

VAR
  len, index : CARDINAL;
  
BEGIN
  len := length(source);
  
  (* bail out if target is too small *)
  IF (len = 0) OR (HIGH(target) <= len) THEN
    RETURN
  END; (* IF *)
  
  index := 0;
  REPEAT
    target[index] := source[index];
    index := index + 1
  UNTIL index = len;
  
  target[index] := NUL
END CopyArray;


PROCEDURE canAppendArray
  ( VAR (*CONST*) target : ARRAY OF CHAR; source : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if source can be appended to target. *)

BEGIN
  RETURN (HIGH(target) > length(source) + length(target))
END canAppendArray;


PROCEDURE AppendArray
  ( VAR target : ARRAY OF CHAR; source : ARRAY OF CHAR );
(* Appends source to target. *)

VAR
  srcLen, tgtLen, srcIndex, tgtIndex : CARDINAL;
  
BEGIN
  srcLen := length(source);
  IF srcLen = 0 THEN
    RETURN
  END; (* IF *)
  
  tgtLen := length(target);
  IF HIGH(target) <= srcLen + tgtLen THEN
    RETURN
  END; (* IF *)
  
  srcIndex := 0;
  tgtIndex := tgtLen;
  REPEAT
    target[tgtIndex] := source[srcIndex];
    tgtIndex := tgtIndex + 1;
    srcIndex := srcIndex + 1
  UNTIL srcIndex = srcLen;
  
  target[tgtIndex] := NUL
END AppendArray;


PROCEDURE canCopyQuotedArray
  ( VAR (*CONST*) target : ARRAY OF CHAR; source : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if target can store the quoted contents of source. *)

BEGIN
  RETURN (HIGH(target) > length(source) + 2)
END canCopyQuotedArray;


PROCEDURE CopyQuotedArray
  ( VAR target : ARRAY OF CHAR; source : ARRAY OF CHAR );
(* Copies source to target, while enclosing contents in quotes. *)

VAR
  srcLen, srcIndex, tgtIndex : CARDINAL;
  
BEGIN
  srcLen := length(source);
  
  (* bail out if target is too small *)
  IF (srcLen = 0) OR (HIGH(target) <= srcLen + 2) THEN
    RETURN
  END; (* IF *)
  
  target[0] := DOUBLEQUOTE;
  
  tgtIndex := 1;
  srcIndex := 0;
  REPEAT
    target[tgtIndex] := source[srcIndex];
    tgtIndex := tgtIndex + 1;
    srcIndex := srcIndex + 1
  UNTIL srcIndex = srcLen;
  
  target[tgtIndex] := DOUBLEQUOTE;
  target[tgtIndex+1] := NUL
END CopyQuotedArray;


(* Insert and Replace Operations *)

PROCEDURE canInsertChars
  ( VAR (*CONST*) target : ARRAY OF CHAR; source : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if source can be inserted into target. *)

BEGIN
  RETURN (HIGH(target) > length(source) + length(target))
END canInsertChars;


PROCEDURE InsertCharsAtIndex
  ( VAR target : ARRAY OF CHAR; source : ARRAY OF CHAR; index : CARDINAL );
(* Inserts source into target starting at index. *)

VAR
  srcLen, tgtLen, srcIndex, tgtIndex : CARDINAL;
  
BEGIN
  srcLen := length(source);
  IF srcLen = 0 THEN
    RETURN
  END; (* IF *)
  
  tgtLen := length(target);
  IF HIGH(target) <= srcLen + tgtLen THEN
    RETURN
  END; (* IF *)
  
  (* move srcLen chars at index to index + srcLen *)
  srcIndex := index;
  tgtIndex := index + srcLen;
  target[tgtIndex + 1] := NUL;
  LOOP
    target[tgtIndex] := target[srcIndex];
    IF (tgtIndex = index) OR (tgtIndex = 0) THEN
      EXIT
    ELSE
      tgtIndex := tgtIndex - 1
    END (* IF *)
  END; (* LOOP *)
    
  (* replace target[index..index+srcLen] with source *)
  srcIndex := 0;
  tgtIndex := index;
  REPEAT
    target[tgtIndex] := source[srcIndex];
    tgtIndex := tgtIndex + 1;
    srcIndex := srcIndex + 1
  UNTIL srcIndex = srcLen
END InsertCharsAtIndex;


PROCEDURE canReplaceCharsAtIndex
  ( VAR (*CONST*) target : ARRAY OF CHAR;
    source : ARRAY OF CHAR; index : CARDINAL ) : BOOLEAN;
(* Returns TRUE if index+length(source) does not exceed length of target. *)

BEGIN
  RETURN (index + length(source) <= length(target))
END canReplaceCharsAtIndex;


PROCEDURE ReplaceCharsAtIndex
  ( VAR target : ARRAY OF CHAR; source : ARRAY OF CHAR; index : CARDINAL );
(* Replaces slice target[index..index+length(source) with source. *)

VAR
  srcLen, srcIndex, tgtIndex : CARDINAL;
  
BEGIN
  srcLen := length(source);
  IF srcLen = 0 THEN
    RETURN
  END; (* IF *)
  
  (* bail out if source is longer than remainder of target at index *)
  IF index + length(source) > length(target) THEN
    RETURN
  END; (* IF *)
  
  (* replace target[index..index+srcLen] with source *)
  srcIndex := 0;
  tgtIndex := index;
  REPEAT
    target[tgtIndex] := source[srcIndex];
    tgtIndex := tgtIndex + 1;
    srcIndex := srcIndex + 1
  UNTIL srcIndex = srcLen
END ReplaceCharsAtIndex;


(* Slice Operations *)

PROCEDURE canCopySlice
  ( VAR (*CONST*) target : ARRAY OF CHAR; start, end : CARDINAL ) : BOOLEAN;
(* Returns TRUE if target can store (end-start+1) characters. *)

BEGIN
  RETURN (HIGH(target) > (end - start + 1))
END canCopySlice;


PROCEDURE CopySlice
  ( VAR target : ARRAY OF CHAR;
    source : ARRAY OF CHAR; start, end : CARDINAL );
(* Copies slice source[start..end] to target. *)

VAR
  srcLen, srcIndex, tgtIndex : CARDINAL;
  
BEGIN
  (* bail out if target capacity is insufficient to append slice *)
  IF (end - start + 1) >= HIGH(target) THEN
    RETURN
  END; (* IF *)
  
  srcLen := length(source);
  
  (* bail out if start and end do not specify a valid slice in source *)
  IF (srcLen = 0) OR (start > end) OR (end >= srcLen) THEN
    RETURN
  END; (* IF *)
  
  tgtIndex := 0;
  FOR srcIndex := start TO end DO
    target[tgtIndex] := source[srcIndex];
    tgtIndex := tgtIndex + 1
  END; (* FOR *)
  
  target[tgtIndex] := NUL
END CopySlice;


PROCEDURE canAppendSlice
  ( VAR (*CONST*) target : ARRAY OF CHAR; start, end : CARDINAL ) : BOOLEAN;
(* Returns TRUE if target can store (end-start+1) additional characters. *)

BEGIN
  RETURN (HIGH(target) > length(target) + (end - start + 1))
END canAppendSlice;


PROCEDURE AppendSlice
  ( VAR target : ARRAY OF CHAR;
    source : ARRAY OF CHAR; start, end : CARDINAL );
(* Appends slice source[start..end] to target. *)

VAR
  srcLen, tgtLen, srcIndex, tgtIndex : CARDINAL;

BEGIN
  tgtLen := length(target);
  
  (* bail out if target capacity is insufficient to append slice *)
  IF HIGH(target) <= tgtLen + (end - start + 1) THEN
    RETURN
  END; (* IF *)
  
  srcLen := length(source);
  
  (* bail out if start and end do not specify a valid slice in source *)
  IF (srcLen = 0) OR (start > end) OR (end >= srcLen) THEN
    RETURN
  END; (* IF *)
  
  tgtIndex := tgtLen;
  FOR srcIndex := start TO end DO
    target[tgtIndex] := source[srcIndex];
    tgtIndex := tgtIndex + 1
  END; (* FOR *)
  
  target[tgtIndex] := NUL
END AppendSlice;


PROCEDURE RemoveSlice ( VAR array : ARRAY OF CHAR; start, end : CARDINAL );
(* Removes slice source[start..end] from array. *)

VAR
  len, srcIndex, tgtIndex : CARDINAL;
  
BEGIN
  len := length(array);
  
  (* bail out if start and end do not specify a valid slice in array *)
  IF (len = 0) OR (start > end) OR (end >= len) THEN
    RETURN
  END; (* IF *)
  
  (* truncate at start if slice is at the end of the array *)
  IF end + 1 = len THEN
    array[start] := NUL;
    RETURN
  END; (* IF *)
  
  (* else copy array[end+1..len] to array[start..] *)
  tgtIndex := start;
  FOR srcIndex := end+1 TO len DO
    array[tgtIndex] := array[srcIndex];
    tgtIndex := tgtIndex + 1
  END (* FOR *)
END RemoveSlice;


(* Word Operations *)

PROCEDURE canCopyWordAtIndex
  ( VAR (*CONST*) target : ARRAY OF CHAR;
    source: ARRAY OF CHAR; n : CARDINAL ) : BOOLEAN;
(* Returns TRUE if target can store the n-th word of source. *)

BEGIN
  (* TO DO *)
END canCopyWordAtIndex;


PROCEDURE CopyWordAtIndex
  ( VAR target : ARRAY OF CHAR; source : ARRAY OF CHAR; n : CARDINAL );
(* Copies the n-th word in source array to target array. *)

BEGIN
  (* TO DO *)
END CopyWordAtIndex;


PROCEDURE canAppendWordAtIndex
  ( VAR (*CONST*) target : ARRAY OF CHAR;
    source : ARRAY OF CHAR; n : CARDINAL ) : BOOLEAN;
(* Returns TRUE if the n-th word of source can be appended to target. *)

BEGIN
  (* TO DO *)
END canAppendWordAtIndex;


PROCEDURE AppendWordAtIndex
  ( VAR target : ARRAY OF CHAR; source : ARRAY OF CHAR; n : CARDINAL );
(* Appends the n-th word in source array to target array. *)

BEGIN
  (* TO DO *)
END AppendWordAtIndex;


PROCEDURE RemoveWordAtIndex ( VAR array : ARRAY OF CHAR; n : CARDINAL );
(* Removes the n-th word in array from array. *)

BEGIN
  (* TO DO *)
END RemoveWordAtIndex;


(* Relational Operations *)

PROCEDURE matches
  ( VAR (*CONST*) array1, array2 : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if the content of array1 matches that of array2. *)

VAR
  index, maxIndex : CARDINAL;
  
BEGIN
  (* limit iteration to range of shorter array *)
  IF HIGH(array1) > HIGH(array2) THEN
    maxIndex := HIGH(array2)
  ELSE
    maxIndex := HIGH(array1)
  END; (* IF *)
  
  (* check for mismatching characters in range [0..maxIndex] *)
  FOR index := 0 TO maxIndex DO
    IF array1[index] # array2[index] THEN
      RETURN FALSE
    END
  END; (* FOR *)
  
  (* case 1 : array1 has reached HIGH, but not array2 *)
  IF (HIGH(array2) > maxIndex) THEN
    RETURN (array2[maxIndex+1] = NUL)
  END; (* IF *)

  (* case 2 : array2 has reached HIGH, but not array1 *)
  IF (HIGH(array1) > maxIndex) THEN
    RETURN (array1[maxIndex+1] = NUL)
  END; (* IF *)
  
  (* case 3 : both array1 and array2 have reached HIGH *)
  RETURN TRUE
END matches;


PROCEDURE collatesBefore
  ( VAR (*CONST*) array1, array2 : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if array1 comes before array2 in ASCII collation order. *)

VAR
  ch1, ch2 : CHAR;
  index, maxIndex : CARDINAL;
  
BEGIN
  (* limit iteration to range of shorter array *)
  IF HIGH(array1) > HIGH(array2) THEN
    maxIndex := HIGH(array2)
  ELSE
    maxIndex := HIGH(array1)
  END; (* IF *)
  
  (* check for mismatching characters in range [0..maxIndex] *)
  FOR index := 0 TO maxIndex DO
    ch1 := array1[index];
    ch2 := array2[index];
    IF ch1 < ch2 THEN
      RETURN TRUE
    ELSIF ch1 > ch2 THEN
      RETURN FALSE
    END
  END; (* FOR *)
    
  (* case 1 : array1 has reached HIGH, but not array2 *)
  IF (HIGH(array2) > maxIndex) THEN
    (* if equal, return FALSE
         because array1 doesn't collate before array2,
       if not equal, return TRUE
         because the shorter (array1) collates before the longer *)
    RETURN (array2[maxIndex+1] # NUL)
  END; (* IF *)

  (* case 2 : array2 has reached HIGH, but not array1 *)
  IF (HIGH(array1) > maxIndex) THEN
    (* if equal, return FALSE
         because array1 doesn't collate before array2,
       if not equal, also return FALSE
         because the longer (array1) doens't collate before the shorter *)
    RETURN FALSE
  END; (* IF *)
  
  (* case 3 : both array1 and array2 have reached HIGH *)
  RETURN FALSE (* equal, but array1 does not collate before array2 *)
END collatesBefore;


PROCEDURE collatesBeforeOrMatches
  ( VAR (*CONST*) array1, array2 : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if array1 comes before array2 in ASCII collation order. *)

VAR
  ch1, ch2 : CHAR;
  index, maxIndex : CARDINAL;
  
BEGIN
  (* limit iteration to range of shorter array *)
  IF HIGH(array1) > HIGH(array2) THEN
    maxIndex := HIGH(array2)
  ELSE
    maxIndex := HIGH(array1)
  END; (* IF *)
  
  (* check for mismatching characters in range [0..maxIndex] *)
  FOR index := 0 TO maxIndex DO
    ch1 := array1[index];
    ch2 := array2[index];
    IF ch1 < ch2 THEN
      RETURN TRUE
    ELSIF ch1 > ch2 THEN
      RETURN FALSE
    END
  END; (* FOR *)
    
  (* case 1 : array1 has reached HIGH, but not array2 *)
  IF (HIGH(array2) > maxIndex) THEN
    (* if equal, return TRUE
         because they match,
       if not equal, also TRUE
         because the shorter (array1) collates before the longer *)
    RETURN TRUE
  END; (* IF *)

  (* case 2 : array2 has reached HIGH, but not array1 *)
  IF (HIGH(array1) > maxIndex) THEN
    (* if equal, return TRUE
         because they match
       if not equal, return FALSE
         because the shorter (array2) collates before the longer *)
    RETURN (array1[maxIndex+1] = NUL)
  END; (* IF *)
  
  (* case 3 : both array1 and array2 have reached HIGH *)
  RETURN TRUE (* because they match *)
END collatesBeforeOrMatches;


(* ************************************************************************ *
 * Private Operations                                                       *
 * ************************************************************************ *)

(* ---------------------------------------------------------------------------
 * procedure FindFirstConsecutiveSpace(array, found, index)
 * ---------------------------------------------------------------------------
 * Searches array, starting at index, from left to right for the first space
 * following a space. If found then TRUE is passed in found and its index in
 * index. Otherwise, FALSE is passed in found and index remains unmodified.
 * ------------------------------------------------------------------------ *)

PROCEDURE FindFirstConsecutiveSpace
  ( VAR (* CONST *) array : ARRAY OF CHAR;
    VAR found : BOOLEAN; VAR index : CARDINAL );

VAR
  ch, nextChar : CHAR;
  searchIndex : CARDINAL;

BEGIN
  (* bail out if index out of bounds *)
  IF index >= HIGH(array) THEN
    RETURN
  END; (* IF *)
  
  (* search for consecutive spaces *)
  searchIndex := index;
  REPEAT
    ch := array[searchIndex];
    searchIndex := searchIndex + 1;
    nextChar := array[searchIndex];
    found := ((ch = SPACE) AND (nextChar = SPACE))
  UNTIL found OR (searchIndex > HIGH(array)) OR (ch = NUL);
  
  IF found THEN
    index := searchIndex
  END (* IF *)
END FindFirstConsecutiveSpace;


(* ---------------------------------------------------------------------------
 * procedure FindCharL2R(array, ch, index)
 * ---------------------------------------------------------------------------
 * Searches array, starting at index, from left to right for the first
 * occurrence of ch. Upon return, index contains the index of ch if found,
 * or the index of the NUL terminator or last index of array if not found.
 * ------------------------------------------------------------------------ *)

PROCEDURE FindCharL2R
  ( VAR (* CONST *) array : ARRAY OF CHAR;
    ch : CHAR; VAR index : CARDINAL );

VAR
  thisChar : CHAR;
  
BEGIN
  (* bail out if index out of bounds *)
  IF index >= HIGH(array) THEN
    RETURN
  END; (* IF *)
  
  (* search for ch *)
  REPEAT
    thisChar := array[index];
    index := index + 1
  UNTIL (index > HIGH(array)) OR (thisChar = NUL) OR (thisChar = ch);
END FindCharL2R;


(* ---------------------------------------------------------------------------
 * procedure FindCharR2L(array, ch, index)
 * ---------------------------------------------------------------------------
 * Searches array, starting at index, from right to left for the first
 * occurrence of ch. Upon return, index contains the index of ch if found,
 * or zero if not found.
 * ------------------------------------------------------------------------ *)

PROCEDURE FindCharR2L
  ( VAR (* CONST *) array : ARRAY OF CHAR;
    ch : CHAR; VAR index : CARDINAL );

VAR
  thisChar : CHAR;
  
BEGIN
  (* bail out if index out of bounds *)
  IF index >= HIGH(array) THEN
    RETURN
  END; (* IF *)
  
  (* search for ch *)
  thisChar := array[index];
  WHILE (index > 0) AND (thisChar # ch) DO
    thisChar := array[index-1];
    index := index - 1
  END (* WHILE *)
END FindCharR2L;


END CharArray.