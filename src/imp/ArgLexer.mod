(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE ArgLexer;

IMPORT Infile, String;

FROM ISO646 IMPORT
  NUL, TAB, NEWLINE, SPACE, SINGLEQUOTE, DOUBLEQUOTE, BACKSLASH;
FROM String IMPORT StringT; (* alias for String.String *)
FROM Infile IMPORT InfileT; (* alias for Infile.Infile *)


VAR
  args : InfileT;
  lexeme : StringT;
  

(* ---------------------------------------------------------------------------
 * function ArgLexer.nextToken()
 * ---------------------------------------------------------------------------
 * Reads and consumes the next commmand line argument and returns its token.
 * ------------------------------------------------------------------------ *)

PROCEDURE nextToken () : Token;

VAR
  next : CHAR;
  token : Token;
  pathExpected, valueExpected : BOOLEAN;
  
BEGIN
  pathExpected := TRUE;
  valueExpected := FALSE;
  
  (* all decisions are based on lookahead *)
  next := Infile.lookaheadChar(args);
  
  (* skip any whitespace, tab and new line *)
  WHILE NOT Infile.eof(args) AND
    ((next = SPACE) OR (next = TAB) OR (next = NEWLINE)) DO
    next := Infile.consumeChar(args)
  END; (* WHILE *)
  
  (* check for end-of-file *)
  IF Infile.eof(args) THEN
    token := EndOfInput;
    lexeme := String.Nil
    
  ELSE
    CASE next OF
    (* next symbol is option *)
    | '-' :
        GetOption(next, token, lexeme);
        
        CASE token OF
          Help .. BuildInfo :
            pathExpected := FALSE
            
        | Outfile :
            pathExpected := TRUE
            
        | Dict .. Newline :
            pathExpected := FALSE
            
        | Verbose :
            pathExpected := TRUE
            
        ELSE
          pathExpected := TRUE
        END (* CASE *)
            
    (* string *)
    | DOUBLEQUOTE,
      SINGLEQUOTE :
        GetValue(next, token, lexeme)
    
    (* number *)
    | '0' .. '9' :
        IF pathExpected THEN
          GetPath(next, token, lexeme)
        ELSE
          GetNumber(next, token, lexeme)
        END (* IF *)
    
    (* equals *)
    | '=' :
        next := Infile.consumeChar(args);
        token := Equals;
        lexeme := String.Nil
    
    (* identifier or path *)
    | 'A' .. 'Z',
      'a' .. 'z' :
        IF pathExpected THEN
          GetPath(next, token, lexeme)
        ELSE
          GetIdent(next, token, lexeme)
        END (* IF *)
    
    ELSE
      IF pathExpected THEN
        GetPath(next, token, lexeme)
      ELSE (* invalid input *)
        GetInvalidInput(next, token, lexeme)
      END (* IF *)
    END (* CASE *)
  END; (* IF *)
  
  RETURN token
END nextToken;


(* ---------------------------------------------------------------------------
 * function ArgLexer.lastArg()
 * ---------------------------------------------------------------------------
 * Returns the argument string of the last consumed argument, or NIL if the
 * token returned by a prior call to nextToken() was Equals or EndOfInput,
 * or if nextToken() has not been called before.
 * ------------------------------------------------------------------------ *)

PROCEDURE lastArg () : StringT;

BEGIN
  RETURN lexeme
END lastArg;


(* ---------------------------------------------------------------------------
 * function ArgLexer.isInfoRequest(token)
 * ---------------------------------------------------------------------------
 * Returns TRUE if token represents an information request, else FALSE.
 * ------------------------------------------------------------------------ *)

PROCEDURE isInfoRequest ( token : Token ) : BOOLEAN;

BEGIN
  RETURN (token >= Help) AND (token <= BuildInfo)
END isInfoRequest;


(* ---------------------------------------------------------------------------
 * function ArgLexer.isExpansionRequest(token)
 * ---------------------------------------------------------------------------
 * Returns TRUE if token represents a compilation request, else FALSE.
 * ------------------------------------------------------------------------ *)

PROCEDURE isExpansionOption ( token : Token ) : BOOLEAN;

BEGIN
  RETURN (token >= Outfile) AND (token <= Newline)
END isExpansionOption;


(* ---------------------------------------------------------------------------
 * function ArgLexer.isParameter(token)
 * ---------------------------------------------------------------------------
 * Returns TRUE if token represents an option parameter, else FALSE.
 * ------------------------------------------------------------------------ *)

PROCEDURE isParameter ( token : Token ) : BOOLEAN;

BEGIN
  RETURN (token >= FileOrPath) AND (token <= Number)
END isParameter;


(* ---------------------------------------------------------------------------
 * function ArgLexer.isDiagnosticOption(token)
 * ---------------------------------------------------------------------------
 * Returns TRUE if token represents a diagnostic option, else FALSE.
 * ------------------------------------------------------------------------ *)

PROCEDURE isDiagnosticOption ( token : Token ) : BOOLEAN;

BEGIN
  RETURN (token >= Verbose) AND (token <= ShowSettings)
END isDiagnosticOption;


(* ************************************************************************ *
 * Private Operations                                                       *
 * ************************************************************************ *)

(* ---------------------------------------------------------------------------
 * private procedure GetOption(next, token, lexeme)
 * ---------------------------------------------------------------------------
 * Reads an option denoter from args and passes the new lookahead character
 * in next, the token of the option in token and its lexeme in lexeme.
 * ------------------------------------------------------------------------ *)

PROCEDURE GetOption
  (VAR next : CHAR; VAR token : Token; VAR lexeme : StringT );

BEGIN
  Infile.MarkLexeme(args);
  
  (* consume first prefix character *)
  next := Infile.consumeChar(args);
  
  (* consume second prefix character *)
  IF next = '-' THEN
    next := Infile.consumeChar(args)
  END; (* IF *)
  
  (* consume all characters until whitespace, '=' or end of input reached *)
  WHILE NOT Infile.eof(args) AND (next # SPACE) AND (next # '=') DO
    next := Infile.consumeChar(args)
  END; (* WHILE *)
  
  (* get the lexeme *)
  lexeme := Infile.lexeme(args);
  
  (* set the token *)
  token := tokenForOptionLexeme(lexeme)
END GetOption;


(* ---------------------------------------------------------------------------
 * private function tokenForOptionLexeme(lexeme)
 * ---------------------------------------------------------------------------
 * Returns the token for an option denoter passed in parameter lexeme,
 * or token Invalid if the lexeme does not represent any option denoter.
 * ------------------------------------------------------------------------ *)

PROCEDURE tokenForOptionLexeme ( lexeme : StringT ) : Token;

BEGIN
  CASE String.length(lexeme) OF
    2 :
      CASE String.charAtIndex(lexeme, 1) OF
        'V' :
          RETURN Version
          
      | 'h' :
          RETURN Help
          
      | 'v' :
          RETURN Verbose
      END (* CASE *)
  
  | 6 :
      CASE String.charAtIndex(lexeme, 2) OF
        'd' :
          IF String.matchesConstArray(lexeme, "--dict") THEN
            RETURN Dict
          END (* IF *)
      
      | 'h' :
          IF String.matchesConstArray(lexeme, "--help") THEN
            RETURN Help
          END (* IF *)
      END (* CASE *)
    
  | 9 :
      CASE String.charAtIndex(lexeme, 5) OF
        'e' :
          IF String.matchesConstArray(lexeme, "--license") THEN
            RETURN License
          END (* IF *)
          
      | 'l' :
          IF String.matchesConstArray(lexeme, "--newline") THEN
            RETURN Newline
          END (* IF *)
          
      | 'f' :
          IF String.matchesConstArray(lexeme, "--outfile") THEN
            RETURN Outfile
          END (* IF *)
          
      | 'b' :
          IF String.matchesConstArray(lexeme, "--verbose") THEN
            RETURN Verbose
          END (* IF *)
          
      | 's' :
          IF String.matchesConstArray(lexeme, "--version") THEN
            RETURN Version
          END (* IF *)
      END (* CASE *)
  
  | 10 :
      IF String.matchesConstArray(lexeme, "--tabwidth") THEN
        RETURN TabWidth
      END (* IF *)
      
  | 12 :
      IF String.matchesConstArray(lexeme, "--build-info") THEN
        RETURN BuildInfo
      END (* IF *)
      
  | 15 :
      IF String.matchesConstArray(lexeme, "--show-settings") THEN
        RETURN ShowSettings
      END (* IF *)
  END; (* CASE *)
  
  RETURN Invalid
END tokenForOptionLexeme;


(* ---------------------------------------------------------------------------
 * private procedure GetPath(next, token, lexeme)
 * ---------------------------------------------------------------------------
 * Reads a character sequence from args until an unescaped whitespace, '=' or
 * end of input is reached, ignoring any backslash escaped whitespace. Passes
 * the character sequence back in lexeme. Passes the new lookahead character
 * in next and FileOrPath in token.
 * ------------------------------------------------------------------------ *)

PROCEDURE GetPath
  (VAR next : CHAR; VAR token : Token; VAR lexeme : StringT );

BEGIN  
  Infile.MarkLexeme(args);
  
  (* consume all characters until whitespace, '=' or end of input reached *)
  WHILE NOT Infile.eof(args) AND (next # SPACE) AND (next # '=') DO
    (* check for escaped whitespace *) 
    IF (next = BACKSLASH) AND (Infile.la2Char(args) = SPACE) THEN
      (* consume backslash *)
      next := Infile.consumeChar(args);
      (* consume escaped whitespace *)
      next := Infile.consumeChar(args)
    END; (* IF *)
    
    next := Infile.consumeChar(args)
  END; (* WHILE *)
  
  (* get the lexeme *)
  lexeme := Infile.lexeme(args);
  
  (* set the token *)
  token := FileOrPath
END GetPath;


(* ---------------------------------------------------------------------------
 * private procedure GetIdent(next, token, lexeme)
 * ---------------------------------------------------------------------------
 * Reads a character sequence starting with a letter from args until white-
 * space, '=' or end of input is reached. Passes the character sequence in
 * lexeme. Passes the new lookahead character in next. If any non-alphanumeric
 * characters are found in the character sequence, Invalid is passed in token,
 * otherwise Ident is passed in token.
 * ------------------------------------------------------------------------ *)

PROCEDURE GetIdent
  (VAR next : CHAR; VAR token : Token; VAR lexeme : StringT );

VAR
  illegalCharsFound : BOOLEAN;
  
BEGIN
  illegalCharsFound := FALSE;
  
  Infile.MarkLexeme(args);
  
  (* consume all characters until whitespace, '=' or end of input reached *)
  WHILE NOT Infile.eof(args) AND (next # SPACE) AND (next # '=') DO
    (* check for illegal characters *) 
    IF (next < '0') OR
       ((next > '9') AND (next < 'A')) OR
       ((next > 'Z') AND (next < 'a')) OR
       (next > 'z') THEN
      illegalCharsFound := TRUE
    END; (* IF *)
    
    next := Infile.consumeChar(args)
  END; (* WHILE *)
  
  (* get the lexeme *)
  lexeme := Infile.lexeme(args);
  
  (* set the token *)
  IF illegalCharsFound THEN
    token := Invalid
  ELSE
    token := Ident
  END (* IF *)
END GetIdent;


(* ---------------------------------------------------------------------------
 * private procedure GetValue(next, token, lexeme)
 * ---------------------------------------------------------------------------
 * Reads a character sequence starting with a single quote or double quote
 * from args until the first whitespace after a closing matching single or
 * double quote or end of input is reached. Passes the character sequence in
 * lexeme. Passes the new lookahead character in next.  If the last character
 * in the sequence does not match the first or if the quote at the start
 * occurs anywhere else than at the start and end, Invalid is passed in token,
 * otherwise Value is passed in token.
 * ------------------------------------------------------------------------ *)

PROCEDURE GetValue
  (VAR next : CHAR; VAR token : Token; VAR lexeme : StringT );

VAR
  last, delimiter : CHAR;
  delimiterCount : CARDINAL;
  
BEGIN
  last := NUL;
  delimiterCount := 1;
  Infile.MarkLexeme(args);
  
  (* get opening delimiter *)
  delimiter := next;
  next := Infile.consumeChar(args);
  
  (* consume all characters until
     first whitespace after closing delimiter or end of input reached *)
  WHILE NOT Infile.eof(args) AND
        NOT ((delimiterCount > 1) AND (next = SPACE)) DO
    (* count delimiters *) 
    IF next = delimiter THEN
      delimiterCount := delimiterCount + 1
    END; (* IF *)
    
    last := next;
    next := Infile.consumeChar(args)
  END; (* WHILE *)
  
  (* get the lexeme *)
  lexeme := Infile.lexeme(args);
  
  (* get the token *)
  IF (delimiterCount # 2) OR (last # delimiter) THEN
    token := Invalid
  ELSE
    token := Value
  END (* IF *)
END GetValue;


(* ---------------------------------------------------------------------------
 * private procedure GetNumber(next, token, lexeme)
 * ---------------------------------------------------------------------------
 * Reads a character sequence starting with a digit from args until white-
 * space or end of input is reached. Passes the character sequence in lexeme.
 * Passes the new lookahead character in next. If any non-digit characters
 * are found in the character sequence, Invalid is passed in token, otherwise
 * Number is passed in token.
 * ------------------------------------------------------------------------ *)

PROCEDURE GetNumber
  (VAR next : CHAR; VAR token : Token; VAR lexeme : StringT );

VAR
  illegalCharsFound : BOOLEAN;
  
BEGIN
  illegalCharsFound := FALSE;
  
  Infile.MarkLexeme(args);
  
  (* consume all characters until whitespace, '=' or end of input reached *)
  WHILE NOT Infile.eof(args) AND (next # SPACE) AND (next # '=') DO
    (* check for illegal characters *) 
    IF (next < '0') OR (next > '9') THEN
      illegalCharsFound := TRUE
    END; (* IF *)
    
    next := Infile.consumeChar(args)
  END; (* WHILE *)
  
  (* get the lexeme *)
  lexeme := Infile.lexeme(args);
  
  (* set the token *)
  IF illegalCharsFound THEN
    token := Invalid
  ELSE
    token := Number
  END (* IF *)
END GetNumber;


BEGIN
  (* set args to already opened file *)
  lexeme := String.Nil
END ArgLexer.