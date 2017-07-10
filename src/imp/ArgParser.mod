(*!m2iso*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE ArgParser;

IMPORT ArgLexer, String, NumStr, Newline, Tabulator;

FROM String IMPORT StringT; (* alias for String.String *)


(* Properties *)

VAR
  srcFile  : StringT;
  errCount : CARDINAL;
  

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
  (* outfile | *)
    ArgLexer.TokenOutfile :
      token := parseOutfile(token)
      
  (* dictionary | *)
  | ArgLexer.TokenDict :
      token := parseDictionary(token)
      
  (* tabWidth | *)
  | ArgLexer.TokenTabWidth :
      token := parseTabWidth(token)
      
  (* newlineMode *)
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
 *   '--tabwidth' Number
 *   ;
 *
 * Number := Digit+ ;
 * ------------------------------------------------------------------------ *)

PROCEDURE parseTabWidth ( token : ArgLexer.Token ) : ArgLexer.Token;

VAR
  value : CARDINAL;
  numStr := StringT;
  status : NumStr.Status;
  
BEGIN
  token := ArgLexer.nextToken();
  
  (* Number *)
  IF token = ArgLexer.Number THEN
    (* get value *)
    numStr := ArgLexer.lastArg();
    NumStr.ToCard(numStr, value, status);
        
    (* set tab width *)
    IF (status = NumStr.Success) AND (value <= Tabulator.MaxTabWidth) THEN
      Tabulator.SetTabWidth(value)
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
  
  CASE String.length(modeStr) OF
    2 :
      CASE String.charAtIndex(modeStr, 0) OF
        'l' :
          IF String.matchesArray(modeStr, "lf") THEN
            Newline.SetMode(Newline.LF)
          END (* IF *)
      | 'c' :
          IF String.matchesArray(modeStr, "cr") THEN
            Newline.SetMode(Newline.CR)
          END (* IF *)
      END (* CASE *)
  | 4 :
      IF String.matchesArray(modeStr, "crlf") THEN
        Newline.SetMode(Newline.CRLF)
      END
  END (* CASE *)
  
  token := ArgLexer.nextToken();
  RETURN token
END parseNewlineMode;


BEGIN (* ArgParser *)
  (* init properties *)
  srcFile := NIL;
  errCount := 0
END ArgParser.