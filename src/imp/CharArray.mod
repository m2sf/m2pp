(*!m2pim*) (* Copyright (c) 2017 B.Kowarsch. All rights reserved. *)

IMPLEMENTATION MODULE CharArray;

(* Character Array Operations *)


(* Introspection *)

PROCEDURE length ( VAR (* CONST *) array : ARRAY OF CHAR ) : CARDINAL;
(* Returns the number of characters in array. *)

BEGIN
  (* TO DO *)
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

BEGIN
  (* TO DO *)
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

BEGIN
  (* TO DO *)
END ToLower;


PROCEDURE ToUpper ( VAR array : ARRAY OF CHAR );
(* Converts all lowercase characters in array to uppercase. *)

BEGIN
  (* TO DO *)
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
  ( VAR (* CONST *) source, target : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if target can store the contents of source. *)

BEGIN
  (* TO DO *)
END canCopyArray;


PROCEDURE CopyArray
  (  VAR (* CONST *) source, target : ARRAY OF CHAR );
(* Copies source to target. *)

BEGIN
  (* TO DO *)
END CopyArray;


PROCEDURE canAppendArray
  ( VAR (* CONST *) source, target : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if source can be appended to target. *)

BEGIN
  (* TO DO *)
END canAppendArray;


PROCEDURE AppendArray
  (  VAR (* CONST *) source, target : ARRAY OF CHAR );
(* Appends source to target. *)

BEGIN
  (* TO DO *)
END AppendArray;


PROCEDURE canCopyQuotedArray
  ( VAR (* CONST *) source, target : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if target can store the quoted contents of source. *)

BEGIN
  (* TO DO *)
END canCopyQuotedArray;


PROCEDURE CopyQuotedArray
  (  VAR (* CONST *) source, target : ARRAY OF CHAR );
(* Copies source to target, while enclosing contents in quotes. *)

BEGIN
  (* TO DO *)
END CopyQuotedArray;


(* Slice Operations *)

PROCEDURE canCopySlice
  ( start, end : CARDINAL; VAR (* CONST *) target : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if target can store (end-start+1) characters. *)

BEGIN
  (* TO DO *)
END canCopySlice;


PROCEDURE CopySlice
  (  start, end : CARDINAL; VAR (* CONST *) source, target : ARRAY OF CHAR );
(* Copies slice source[start..end] to target. *)

BEGIN
  (* TO DO *)
END CopySlice;


PROCEDURE canAppendSlice
  ( start, end : CARDINAL; VAR (* CONST *) target : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if target can store (end-start+1) additional characters. *)

BEGIN
  (* TO DO *)
END canAppendSlice;


PROCEDURE AppendSlice
  (  start, end : CARDINAL; VAR (* CONST *) source, target : ARRAY OF CHAR );
(* Appends slice source[start..end] to target. *)

BEGIN
  (* TO DO *)
END AppendSlice;


PROCEDURE RemoveSlice
  (  start, end : CARDINAL; VAR (* CONST *) array : ARRAY OF CHAR );
(* Removes slice source[start..end] from array. *)

BEGIN
  (* TO DO *)
END RemoveSlice;


(* Word Operations *)

PROCEDURE canCopyWordAtIndex
  (  n : CARDINAL; VAR (* CONST *) source, target : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if target can store the n-th word of source. *)

BEGIN
  (* TO DO *)
END canCopyWordAtIndex;


PROCEDURE CopyWordAtIndex
  (  n : CARDINAL; VAR (* CONST *) source, target : ARRAY OF CHAR );
(* Copies the n-th word in source array to target array. *)

BEGIN
  (* TO DO *)
END CopyWordAtIndex;


PROCEDURE canAppendWordAtIndex
  (  n : CARDINAL; VAR (* CONST *) source, target : ARRAY OF CHAR ) : BOOLEAN;
(* Returns TRUE if target can be appended the n-th word of source. *)

BEGIN
  (* TO DO *)
END canAppendWordAtIndex;


PROCEDURE AppendWordAtIndex
  (  n : CARDINAL; VAR (* CONST *) source, target : ARRAY OF CHAR );
(* Appends the n-th word in source array to target array. *)

BEGIN
  (* TO DO *)
END AppendWordAtIndex;


PROCEDURE RemoveWordAtIndex
  (  n : CARDINAL; VAR (* CONST *) array : ARRAY OF CHAR );
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