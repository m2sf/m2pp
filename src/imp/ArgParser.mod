(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE ArgParser;

IMPORT ArgLexer, Settings, String, NumStr, Newline, Tabulator;

FROM String IMPORT StringT; (* alias for String.String *)


(* Properties *)

VAR
  errCount : CARDINAL;
  
  
(* Public Operations *)

(* ---------------------------------------------------------------------------
 * function parseArgs()
 * ---------------------------------------------------------------------------
 * Parses command line arguments and initalises dictionary accordingly.
 *
 * args :
 *   infoRequest | expansionRequest diagOption*
 *   ;
 * ------------------------------------------------------------------------ *)

PROCEDURE parseArgs () : Status;

VAR
  token : ArgLexer.Token;
  
BEGIN
  token := ArgLexer.nextToken();
  
  IF ArgLexer.isInfoRequest(token) THEN
    token := parseInfoRequest(token)
    
  ELSIF ArgLexer.isExpansionRequest(token) THEN
    token := parseExpansionRequest(token);
    
    WHILE ArgLexer.isDiagnosticsOption(token) THEN
      token := parseDiagOption(token)
    END (* IF *)
    
  ELSIF token = ArgLexer.EndOfInput THEN
    ReportMissingSourceFile
  END; (* IF *)
  
  WHILE token # ArgLexer.EndOfInput DO
    ReportExcessArgument(ArgLexer.lastArg());
    token := ArgLexer.nextToken()
  END; (* WHILE *)
  
  IF errCount > 0 THEN
    status = ErrorsEncountered
  END; (* IF *)
  
  RETURN status
END parseArgs;


(* ---------------------------------------------------------------------------
 * function errorCount()
 * ---------------------------------------------------------------------------
 * Returns the count of errors encountered while parsing the arguments.
 * ------------------------------------------------------------------------ *)

PROCEDURE errorCount () : CARDINAL;

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
    ArgLexer.Help :
      status := Status.HelpRequested
  
  (* --version, -V *)  
  | ArgLexer.Version :
      status := Status.VersionRequested
  
  (* --license *)
  | ArgLexer.License :
      status := Status.LicenseRequested
  
  (* --build-info *)
  | ArgLexer.BuildInfo :
      status := Status.BuildInfoRequested
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
  IF token = ArgLexer.FileOrPath THEN
    Settings.SetInfile(ArgLexer.lastArg());
    token := ArgLexer.nextToken()
    
  ELSE
    ReportMissingSourceFile()
  END; (* IF *)
  
  (* option* *)
  WHILE ArgLexer.isExpansionOption(token) DO
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
    ArgLexer.Outfile :
      token := parseOutfile(token)
      
  (* dictionary | *)
  | ArgLexer.Dict :
      token := parseDictionary(token)
      
  (* tabWidth | *)
  | ArgLexer.TabWidth :
      token := parseTabWidth(token)
      
  (* newlineMode *)
  | ArgLexer.Newline :
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

VAR
  outfileStr : StringT;
  
BEGIN
  (* get lexeme of current symbol *)
  outfileStr := ArgLexer.lastArg();
  
  (* set outfile if not already set before *)
  IF Settings.alreadySet(Settings.Outfile) THEN
    ReportDuplicate("--outfile", outfileStr)
  ELSE
    Settings.SetOutfile(outfileStr)
  END; (* IF *)
  
  (* consume current symbol and return next *)
  RETURN ArgLexer.nextToken()
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
  key := String.Nil;
  value := String.Nil;
  
  (* consume --dict, get next symbol *)
  token := ArgLexer.nextToken();
  
  (* bail out if option *)
  IF ArgLexer.isOption(token) THEN
    (* key/value pair missing *)
    ReportMissingKeyValuePair;
    RETURN token
  END; (* IF *)
  
  (* check for missing key *)
  IF token = ArgLexer.Equals THEN
    (* key missing *)
    ReportMissingKey;
    
    (* skip '=' *)
    token := ArgLexer.nextToken();
    
    (* skip following value *)
    IF ArgLexer.isParameter(token) THEN
      token := ArgLexer.nextToken()
    END (* IF *)
  END; (* IF *)  
    
  WHILE ArgLexer.isParameter(token) DO
    (* key *)
    key := ArgLexer.lastArg()
    
    (* '=' *)
    token := ArgLexer.nextToken();
    IF token = ArgLexer.Equals THEN
      (* value *)
      token := ArgLexer.nextToken();
      IF ArgLexer.isParameter(token) THEN
        value := ArgLexer.lastArg();
        
        (* store key/value pair in dictionary *)
        IF (key # String.Nil) AND (value # String.Nil) THEN
          Dictionary.StoreValueForKey(key, value);
          key := String.Nil; value := String.Nil
        END (* IF *)
      END; (* IF *)
      
      (* get next symbol *)
      token := ArgLexer.nextToken()
    
    (* '=' is missing *)
    ELSE
      ReportMissingPunctuation
    END (* IF *)
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
  (* consume --tabwidth, get next symbol *)
  token := ArgLexer.nextToken();
  
  (* bail out if not number *)
  IF token # ArgLexer.Number THEN
    ReportMissingValue;
    RETURN token
  END; (* IF *)
  
  (* Number *)
  numStr := ArgLexer.lastArg();
  NumStr.ToCard(numStr, value, status);
  
  (* bail out if not a number *)
  IF status # Success THEN
    ReportInvalidParam;
    RETURN ArgLexer.nextToken()
  END; (* IF *)
  
  (* bail out if value is out of range *)
  IF value <= Tabulator.MaxTabWidth THEN
    ReportParamOutOfRange;
    RETURN ArgLexer.nextToken()
  END; (* IF *)
  
  (* set tab width if not already set before *)
  IF Settings.alreadySet(Settings.TabWidth) THEN
    ReportDuplicate("--tabwidth", numStr)
  ELSE
    Settings.SetTabWidth(value)
  END; (* IF *)
  
  RETURN ArgLexer.nextToken()
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
  modeStr : StringT;
  mode : Newline.Mode;
  
BEGIN
  modeStr := NIL;
  
  (* consume --newline, get next symbol *)
  token := ArgLexer.nextToken();  
  
  (* bail out if not identifier *)
  IF token # ArgLexer.Identifier THEN
    ReportMissingMode;
    RETURN token
  END; (* IF *)
  
  (* mode *)
  modeStr := ArgLexer.lexeme();
  
  (* bail out if option *)
  IF (String.charAtIndex(mode, 0) = '-') THEN
    (* option found, mode argument missing *)
    ReportMissingMode;
    RETURN token
  END; (* IF *)
  
  (* get mode from modeStr *)
  CASE String.length(modeStr) OF
    2 :
      CASE String.charAtIndex(modeStr, 0) OF
        'l' :
          IF String.matchesArray(modeStr, "lf") THEN
            mode := Newline.LF
          END (* IF *)
          
      | 'c' :
          IF String.matchesArray(modeStr, "cr") THEN
            mode := Newline.CR
          END (* IF *)
      END (* CASE *)
      
  | 4 :
      IF String.matchesArray(modeStr, "crlf") THEN
        mode := Newline.CRLF
      END
      
  (* bail out if unknown mode *)
  ELSE
    ReportUnknownParam(modeStr);
    RETURN ArgLexer.nextToken()
  END (* CASE *)
  
  (* set mode if not already set before *)
  IF Settings.alreadySet(Settings.NewlineMode) THEN
    ReportDuplicate("--newline", modeStr)
  ELSE
    Settings.SetNewlineMode(mode)
  END; (* IF *)
  
  RETURN ArgLexer.nextToken()
END parseNewlineMode;


(* ---------------------------------------------------------------------------
 * function parseDiagOption(token)
 * ---------------------------------------------------------------------------
 * diagOption :=
 *   '--verbose' | '-v' | '--show-settings'
 *   ;
 * ------------------------------------------------------------------------ *)

PROCEDURE parseDiagOption ( token : ArgLexer.Token ) : ArgLexer.Token;

BEGIN
  CASE token OF
    Verbose :
      IF Settings.alreadySet(Settings.Verbose) THEN
        ReportDuplicate
      ELSE
        Settings.SetVerbose(TRUE)
      END (* IF *)
      
  | ShowSettings :
      IF Settings.alreadySet(Settings.ShowSettings) THEN
        ReportDuplicate
      ELSE
        Settings.SetShowSettings(TRUE)
      END (* IF *)
  END; (* CASE *)
  
  RETURN ArgLexer.nextToken()
END parseDiagOption;


BEGIN (* ArgParser *)
  errCount := 0
END ArgParser.