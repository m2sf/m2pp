(*!m2iso*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE ArgParser;

IMPORT ArgLexer, Newline;

FROM String IMPORT StringT; (* alias for String.String *)


(* Properties *)

VAR
  srcFile  : StringT;
  errCount : CARDINAL;
  tabwidth : CARDINAL [0..8];
  crlfMode : Newline.Mode;
  

(* Public Operations *)

(* ---------------------------------------------------------------------------
 * function parseArgs()
 * ---------------------------------------------------------------------------
 * Parses command line arguments and initalises dictionary accordingly.
 *
 * args :
 *   infoRequest | expansionRequest
 *   ;
 * ------------------------------------------------------------------------ *)

PROCEDURE parseArgs : Status;

BEGIN
  sym := ArgLexer.nextToken();
  
  IF ArgLexer.isInfoRequest(sym) THEN
    sym := parseInfoRequest(sym)
    
  ELSIF ArgLexer.isExpansionRequest(sym) THEN
    sym := parseExpansionRequest(sym)
    
  ELSIF sym = ArgLexer.EndOfInput THEN
    ReportMissingSourceFile
  END; (* IF *)
  
  WHILE sym # ArgLexer.EndOfInput DO
    ReportExcessArgument(ArgLexer.lastArg());
    sym := ArgLexer.nextToken()
  END; (* WHILE *)
  
  IF errCount > 0 THEN
    status = ErrorsEncountered
  END; (* IF *)
  
  RETURN status
END parseArgs;


(* ---------------------------------------------------------------------------
 * function sourceFile()
 * ---------------------------------------------------------------------------
 * Returns a string with the source file argument.
 * ------------------------------------------------------------------------ *)

PROCEDURE sourceFile : StringT;

BEGIN
  RETURN srcFile
END sourceFile;


(* ---------------------------------------------------------------------------
 * function errorCount()
 * ---------------------------------------------------------------------------
 * Returns the count of errors encountered while parsing the arguments.
 * ------------------------------------------------------------------------ *)

PROCEDURE errorCount : CARDINAL;

BEGIN
  RETURN errCount
END errorCount;


(* Private Operations *)

(* ---------------------------------------------------------------------------
 * function parseInfoRequest(token)
 * ---------------------------------------------------------------------------
 * infoRequest :=
 *   --help | -h | --version | -V | --license
 *   ;
 * ------------------------------------------------------------------------ *)

PROCEDURE parseInfoRequest ( token : ArgLexer.Token ) : ArgLexer.Token;

BEGIN
  CASE token OF
  (* --help, -h *)
    ArgLexer.Help : status := Status.HelpRequested
  
  (* --version, -V *)  
  | ArgLexer.Version : status := Status.VersionRequested
  
  (* --license *)
  | ArgLexer.License : status := Status.LicenseRequested
  
  END; (* CASE *)
  
  RETURN ArgLexer.nextToken()
END parseInfoRequest;


(* ---------------------------------------------------------------------------
 * function parseExpansionRequest(token)
 * ---------------------------------------------------------------------------
 * expansionRequest :=
 *   sourceFile option*
 *   ;
 * ------------------------------------------------------------------------ *)

PROCEDURE parseExpansionRequest ( token : ArgLexer.Token ) : ArgLexer.Token;

BEGIN
  (* sourceFile *)
  IF token = ArgLexer.SourceFile THEN
    token := parseCapabilities(token)
  ELSE
    ReportMissingSourceFile()
  END; (* IF *)
  
  (* option* *)
  WHILE ArgLexer.isOption(token) DO
    token := parseOption(token)
  END; (* WHILE *)
  
  RETURN token
END parseExpansionRequest;


(* ---------------------------------------------------------------------------
 * function parseOption(token)
 * ---------------------------------------------------------------------------
 * options :=
 *   outfile | dictionary | tabWidth | newlineMode
 *   ;
 * ------------------------------------------------------------------------ *)

PROCEDURE parseOption ( token : ArgLexer.Token ) : ArgLexer.Token;

BEGIN
  (* outfile | dictionary | tabWidth | newlineMode *)
  CASE token OF
    ArgLexer.TokenOutfile :
      token := parseOutfile(token)
  | ArgLexer.TokenDict :
      token := parseDictionary(token)
  | ArgLexer.TokenTabWidth :
      token := parseTabWidth(token)
  | ArgLexer.TokenNewline :
      token := parseNewlineMode(token)
  END; (* CASE *)
  
  RETURN token
END parseOption;


(* ---------------------------------------------------------------------------
 * function parseOutfile(token)
 * ---------------------------------------------------------------------------
 * outfile :=
 *   '--outfile' filename
 *   ;
 *
 * filename :=
 *   <platform dependent path/filename>
 *   ;
 * ------------------------------------------------------------------------ *)

PROCEDURE parseOutfile ( token : ArgLexer.Token ) : ArgLexer.Token;

BEGIN
  (* TO DO *)
  RETURN token
END parseOutfile;


(* ---------------------------------------------------------------------------
 * function parseDictionary(token)
 * ---------------------------------------------------------------------------
 * dictionary :=
 *   '--dict' keyValuePair+
 *   ;
 *
 * keyValuePair :=
 *   key '=' value
 *   ;
 *
 * alias key = StdIdent ;
 *
 * alias value = StdIdent ;
 * ------------------------------------------------------------------------ *)

PROCEDURE parseDictionary ( token : ArgLexer.Token ) : ArgLexer.Token;

VAR
  key, value : StringT;
  
BEGIN
  key := NIL;
  value := NIL;
  token := ArgLexer.nextToken();
  
  (* ( key '=' value )+ *)
  IF token # ArgLexer.Identifier THEN
    (* error: missing key *)
  END; (* IF *)
  
  WHILE token = ArgLexer.Identifier DO
    (* key *)
    key := ArgLexer.lexeme()
    
    (* '=' *)
    token := ArgLexer.nextToken();
    IF token # ArgLexer.Equals THEN
      (* error: missing '=' *)
    END; (* IF *)
    
    (* value *)
    token := ArgLexer.nextToken();
    IF token = ArgLexer.Identifier THEN
      value := ArgLexer.lexeme()
    END; (* IF *)
    
    (* store key/value pair in dictionary *)
    IF (key # NIL) AND (value # NIL) THEN
      Dictionary.StoreValueForKey(key, value);
      key := NIL; value := NIL
    END; (* IF *)
    
    token := ArgLexer.nextToken();
  END; (* WHILE *)

  RETURN token  
END parseDictionary;


(* ---------------------------------------------------------------------------
 * function parseTabWidth(token)
 * ---------------------------------------------------------------------------
 * tabWidth :=
 *   '--tabwidth' digit0to8
 *   ;
 *
 * digit0to8 := '0' .. '8' ;
 * ------------------------------------------------------------------------ *)

PROCEDURE parseTabWidth ( token : ArgLexer.Token ) : ArgLexer.Token;

VAR
  digit : CARDINAL;
  
BEGIN
  token := ArgLexer.nextToken();
  
  (* digit0to8 *)
  IF token = ArgLexer.Digit THEN
    value := ArgLexer.digit();
    
    (* set tab width *)
    IF value <= 8 THEN
      tabWidth := value
    END; (* IF *)
    
    token := ArgLexer.nextToken()
  END; (* END *)
  
  RETURN token
END parseTabWidth;


(* ---------------------------------------------------------------------------
 * function parseNewlineMode(token)
 * ---------------------------------------------------------------------------
 * newlineMode :=
 *   '--newline' mode
 *   ;
 *
 * mode := 'lf' | 'cr' | 'crlf' ;
 * ------------------------------------------------------------------------ *)

PROCEDURE parseNewlineMode ( token : ArgLexer.Token ) : ArgLexer.Token;

VAR
  mode : StringT;
  
BEGIN
  mode := NIL;
  token := ArgLexer.nextToken();
  
  (* mode *)
  IF token = ArgLexer.Identifier THEN
    mode := ArgLexer.lexeme
  END; (* IF *)
  
  IF String.matchesArray(mode, "lf") THEN
    crlfMode := Newline.LF
    
  ELSIF String.matchesArray(mode, "cr") THEN
    crlfMode := Newline.CR
  
  ELSIF String.matchesArray(mode, "") THEN
    crlfMode := Newline.CRLF
  
  ELSE
    (* error: unrecognised mode *)
    
    RETURN token
  END; (* IF *)
  
  token := ArgLexer.nextToken();
  RETURN token
END parseNewlineMode;


BEGIN (* ArgParser *)
  (* init properties *)
  srcFile := NIL;
  errCount := 0;
  tabwidth := 0;
  crlfMode := Newline.LF
END ArgParser.