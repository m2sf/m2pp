(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation. *)

IMPLEMENTATION MODULE CharArray;

(* Character Array Operations *)


(* Introspection *)

PROCEDURE length ( VAR (* CONST *) array : ARRAY OF CHAR ) : CARDINAL;
(* Returns the number of characters in array. *)

VAR
  len : CARDINAL;
  
BEGIN
  len := 0;
  WHILE len < HIGH(array) AND array[len] # NUL DO
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
  len, index, tgtIndex, srcIndex : CARDINAL;
  
BEGIN
  len := length(array);
  
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
  
  IF index = 0 THEN
    RETURN
  END; (* IF *)
  
  (* copy array[index..len] to array[0..] *)
  tgtIndex := 0;
  FOR srcIndex := startIndex TO len DO
    array[tgtIndex] := array[srcIndex];
    tgtIndex := tgtIndex + 1
  END (* FOR *)
END Trim;


PROCEDURE Collapse ( VAR array : ARRAY OF CHAR );
(* Replaces consecutive whitespace in array with single whitespace. *)

BEGIN
  (* TO DO *)
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
  ( VAR (* CONST *) target, source : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if target can store the contents of source. *)

BEGIN
  RETURN (HIGH(target) > length(source))
END canCopyArray;


PROCEDURE CopyArray
  (  VAR target, (* CONST *) source : ARRAY OF CHAR );
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
  ( VAR (* CONST *) target, source : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if source can be appended to target. *)

BEGIN
  RETURN (HIGH(array)-length(target) > length(source))
END canAppendArray;


PROCEDURE AppendArray
  (  VAR target, (* CONST *) source : ARRAY OF CHAR );
(* Appends source to target. *)

VAR
  srcLen, tgtLen, srcIndex, tgtIndex : CARDINAL;
  
BEGIN
  srcLen := length(source);
  IF srcLen = 0 THEN
    RETURN
  END; (* IF *)
  
  tgtLen := length(target);
  IF HIGH(array)-tgtLen <= srcLen THEN
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
  ( VAR (* CONST *) target, source : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if target can store the quoted contents of source. *)

BEGIN
  RETURN (HIGH(target) > length(source) + 2)
END canCopyQuotedArray;


PROCEDURE CopyQuotedArray
  (  VAR target, (* CONST *) source : ARRAY OF CHAR );
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
  ( VAR (* CONST *) target, source : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if source can be inserted into target. *)

BEGIN
  RETURN (HIGH(array)-length(target) > length(source))
END canInsertChars;


PROCEDURE InsertCharsAtIndex
  ( VAR target, (* CONST *) source : ARRAY OF CHAR; index : CARDINAL );
(* Inserts source into target starting at index. *)

VAR
  srcLen, tgtLen, srcIndex, tgtIndex : CARDINAL;
  
BEGIN
  srcLen := length(source);
  IF srcLen = 0 THEN
    RETURN
  END; (* IF *)
  
  tgtLen := length(target);
  IF HIGH(array)-tgtLen <= srcLen THEN
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
  ( VAR (* CONST *) target, source : ARRAY OF CHAR;
    index : CARDINAL ) : BOOLEAN;
(* Returns TRUE if index+length(source) does not exceed length of target. *)

BEGIN
  RETURN (index + length(source) <= length(target))
END canReplaceCharsAtIndex;


PROCEDURE ReplaceCharsAtIndex
  ( VAR target, (* CONST *) source : ARRAY OF CHAR; index : CARDINAL );
(* Replaces slice target[index..index+length(source) with source. *)

VAR
  srcLen : CARDINAL;
  
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
  ( VAR (* CONST *) target : ARRAY OF CHAR; start, end : CARDINAL ) : BOOLEAN;
(* Returns TRUE if target can store (end-start+1) characters. *)

BEGIN
  RETURN (HIGH(target) > (end - start + 1))
END canCopySlice;


PROCEDURE CopySlice
  ( VAR target, (* CONST *) source : ARRAY OF CHAR; start, end : CARDINAL );
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
  IF (srcLen = 0) OR (start > end) OR (end >= len) THEN
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
  ( VAR (* CONST *) target : ARRAY OF CHAR; start, end : CARDINAL ) : BOOLEAN;
(* Returns TRUE if target can store (end-start+1) additional characters. *)

BEGIN
  RETURN (HIGH(target) > length(target) + (end - start + 1))
END canAppendSlice;


PROCEDURE AppendSlice
  ( VAR target, (* CONST *) source : ARRAY OF CHAR; start, end : CARDINAL );
(* Appends slice source[start..end] to target. *)

VAR
  srcLen, tgtLen, srcIndex, tgtIndex : CARDINAL;

BEGIN
  tgtLen := length(target);
  
  (* bail out if target capacity is insufficient to append slice *)
  IF tgtLen + (end - start + 1) >= HIGH(target) THEN
    RETURN
  END; (* IF *)
  
  srcLen := length(source);
  
  (* bail out if start and end do not specify a valid slice in source *)
  IF (srcLen = 0) OR (start > end) OR (end >= len) THEN
    RETURN
  END; (* IF *)
  
  tgtIndex := tgtLen;
  FOR srcIndex := start TO end DO
    target[tgtIndex] := source[srcIndex];
    tgtIndex := tgtIndex + 1
  END; (* FOR *)
  
  target[tgtIndex] := NUL
END AppendSlice;


PROCEDURE RemoveSlice
  ( VAR (* CONST *) array : ARRAY OF CHAR; start, end : CARDINAL );
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
  ( VAR (* CONST *) target, source : ARRAY OF CHAR; n : CARDINAL ) : BOOLEAN;
(* Returns TRUE if target can store the n-th word of source. *)

BEGIN
  (* TO DO *)
END canCopyWordAtIndex;


PROCEDURE CopyWordAtIndex
  ( VAR target, (* CONST *) source : ARRAY OF CHAR; n : CARDINAL );
(* Copies the n-th word in source array to target array. *)

BEGIN
  (* TO DO *)
END CopyWordAtIndex;


PROCEDURE canAppendWordAtIndex
  ( VAR (* CONST *) target, source : ARRAY OF CHAR; n : CARDINAL ) : BOOLEAN;
(* Returns TRUE if target can be appended the n-th word of source. *)

BEGIN
  (* TO DO *)
END canAppendWordAtIndex;


PROCEDURE AppendWordAtIndex
  ( VAR target, (* CONST *) source : ARRAY OF CHAR; n : CARDINAL );
(* Appends the n-th word in source array to target array. *)

BEGIN
  (* TO DO *)
END AppendWordAtIndex;


PROCEDURE RemoveWordAtIndex
  ( VAR (* CONST *) array : ARRAY OF CHAR; n : CARDINAL );
(* Removes the n-th word in array from array. *)

BEGIN
  (* TO DO *)
END RemoveWordAtIndex;


(* Relational Operations *)

PROCEDURE matches
  ( VAR (* CONST *) array1, array2 : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if the content of array1 matches that of array2. *)

BEGIN
  (* TO DO *)
END matches;


PROCEDURE collatesBefore
  ( VAR (* CONST *) array1, array2 : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if array1 comes before array2 in ASCII collation order. *)

BEGIN
  (* TO DO *)
END collatesBefore;


PROCEDURE collatesBeforeOrMatches
  ( VAR (* CONST *) array1, array2 : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if array1 comes before array2 in ASCII collation order. *)

BEGIN
  (* TO DO *)
END collatesBeforeOrMatches;


END CharArray.