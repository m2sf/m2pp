(*!m2iso*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

MODULE M2PP;

(* Modula-2 Preprocessor Driver *)

IMPORT ProgramArgs, ArgParser, Infile, Outfile, Preprocessor;
FROM FileSystemAdapter IMPORT fileExists, DeleteFile;

FROM Infile IMPORT InfileT; (* alias for Infile.Infile *)
FROM Outfile IMPORT OutfileT; (* alias for Outfile.Outfile *)


CONST
  MaxPathLen = 255;
  ProgTitle = "M2PP - Modula-2 Preprocessor";
  Version   = "Version 0.1\n";
  Copyright = "Copyright (c) 2017 Modula-2 Software Foundation\n";
  License   = "Licensed under the LGPL license version 2.1\n";


PROCEDURE PrintBanner;

BEGIN
  Console.WriteChars(ProgTitle); Console.WriteChars(", ");
  Console.WriteChars(Version);
  Console.WriteChars(Copyright)
END PrintBanner;


PROCEDURE PrintUsage;

BEGIN
  Console.WriteChars("Usage:\n");
  Console.WriteChars("$ m2pp infoRequest\n"); Console.WriteChars("or\n");
  Console.WriteChars("$ m2pp sourceFile option* diagnostic*\n\n");
  
  Console.WriteChars("infoRequest:\n");
  Console.WriteChars(" --help, -h           : print help\n");
  Console.WriteChars(" --version, -V        : print version\n");
  Console.WriteChars(" --license            : print license info\n\n");
  
  Console.WriteChars("option:\n");  
  Console.WriteChars(" --outfile targetFile : define outfile\n");
  Console.WriteChars(" --dict keyValuePair+ : define key/value pairs\n");
  Console.WriteChars(" --tabwidth number    : set tab width\n");
  Console.WriteChars(" --newline mode       : set newline mode\n\n");
  
  Console.WriteChars("diagnostic:\n");
  Console.WriteChars(" --verbose, -v        : verbose output\n");
  Console.WriteChars(" --show-settings      : print all settings\n\n");
  
  Console.WriteChars("keyValuePair:\n");
  Console.WriteChars(" key=value\n\n");
  
  Console.WriteChars("key:\n");
  Console.WriteChars(" identifier\n\n");
  
  Console.WriteChars("value:\n");
  Console.WriteChars
    (" identifier | number | singleQuotedString | doubleQuotedString\n\n");
  
  Console.WriteChars("mode:\n");
  Console.WriteChars(" cr | lf | crlf\n\n")
END PrintUsage;


PROCEDURE PreflightCheck
  ( VAR infile : InfileT; VAR outfile : OutfileT; VAR passed : BOOLEAN );

VAR
  len : CARDINAL;
  pathStr : StringT;
  status : BasicFileIO.Status;
  path : ARRAY [0..MaxPathLen] OF CHAR;

BEGIN
  pathStr := Settings.infile();
  String.CopyToArray(pathStr, path, len);
  
  IF len = 0 THEN
    Console.WriteChars("source path too long.\n");
    passed := FALSE;
    RETURN
  END; (* IF *)
  
  (* bail out if infile does not exist *)
  IF NOT fileExists(path) THEN
    Console.WriteChars("sourcefile not found.\n");
    passed := FALSE;
    RETURN
  END; (* IF *)
    
  Infile.Open(infile, status);
  
  IF status # Success THEN
    Console.WriteChars("unable to open sourcefile.\n");
    infile := Infile.Nil;
    passed := FALSE;
    RETURN
  END; (* IF *)
  
  IF NOT Settings.alreadySet(Settings.Outfile) THEN
    (* generate outfile name from infile name *)
  ELSE
    pathStr := Settings.outfile()
  END; (* IF *)
  
  String.CopyToArray(pathStr, path, len);
  
  IF len = 0 THEN
    Console.WriteChars("target path too long.\n");
    passed := FALSE;
    RETURN
  END; (* IF *)
  
  IF fileExists(path) THEN
    (* rename existing file *)
  END; (* IF *)
  
  Outfile.Open(outfile, status);
  
  IF status # Success THEN
    Console.WriteChars("unable to create targetfile.\n");
    Infile.Close(infile);
    infile := Infile.Nil;
    outfile := Outfile.Nil;
    passed := FALSE;
    RETURN
  END; (* IF *)
  
  (* all preflight checks passed *)
  passed := TRUE;
END PreflightCheck;


VAR
  passed : BOOLEAN;
  infile : InfileT;
  outfile : OutfileT;
  argStatus : ArgParser.Status;
  

BEGIN (* M2PP *)
  (* check if program argument file is present *)
  IF fileExists(ProgramArgs.Filename) THEN
    ProgramArgs.Open
  ELSE (* query user and write file *)
    ProgramArgs.Query
  END; (* IF *)
  
  argStatus := ArgParser.parseArgs();
  ProgramArgs.Close;
  
  CASE argStatus OF
    Success :
      PrintBanner;
      
      PreflightCheck(infile, outfile, passed);
      
      IF passed THEN
        Preprocessor.Expand(infile, outfile);
        Infile.Close(infile);
        Outfile.Close(outfile)
      ELSE
        (* unable to proceed *)
      END (* IF *)
            
  | HelpRequested :
      PrintUsage
      
  | VersionRequested :
      Console.WriteChars(Version)
  
  | LicenseRequested :
      Console.WriteChars(Copyright);
      Console.WriteChars(License)
      
  | ErrorsEncountered :
      (* TO DO *)
  END (* CASE *)
END M2PP.